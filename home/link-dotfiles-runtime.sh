#!/usr/bin/env bash

platform="@platform@"
homeDir="@homeDir@"

find_repo_root_from_dir() {
	local start_dir current_dir

	start_dir="$1"
	[ -n "$start_dir" ] || return 1
	[ -d "$start_dir" ] || return 1

	current_dir="$(cd "$start_dir" && pwd)"

	while [ "$current_dir" != "/" ]; do
		if [ -d "$current_dir/dotfiles" ] && [ -f "$current_dir/flake.nix" ]; then
			printf '%s\n' "$current_dir"
			return 0
		fi
		current_dir="$(dirname "$current_dir")"
	done

	if [ -d "/dotfiles" ] && [ -f "/flake.nix" ]; then
		printf '/\n'
		return 0
	fi

	return 1
}

find_repo_root() {
	local candidate

	for candidate in \
		"${NIXOS_CONFIG_ROOT:-}" \
		"${NIXOS_CONFIG:-}" \
		"${PWD:-}" \
		"${XDG_CONFIG_HOME:-$homeDir/.config}" \
		"$homeDir"; do
		if candidate="$(find_repo_root_from_dir "$candidate" 2>/dev/null)"; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done

	while IFS= read -r candidate; do
		candidate="$(dirname "$candidate")"
		if [ -d "$candidate/dotfiles" ] && [ -f "$candidate/flake.nix" ]; then
			printf '%s\n' "$candidate"
			return 0
		fi
	done < <(find "$homeDir" -maxdepth 3 -name flake.nix -type f 2>/dev/null)

	return 1
}

is_linked_skill_mirror() {
	local target_dir source_dir entry rel source_entry link

	target_dir="$1"
	source_dir="$2"

	while IFS= read -r -d "" entry; do
		rel="${entry#"$target_dir/"}"
		source_entry="$source_dir/$rel"

		if [ -L "$entry" ]; then
			link="$(readlink "$entry" 2>/dev/null || true)"
			if [ "$link" != "$source_entry" ]; then
				return 1
			fi
		elif [ -d "$entry" ]; then
			if ! is_linked_skill_mirror "$entry" "$source_entry"; then
				return 1
			fi
		else
			return 1
		fi
	done < <(find "$target_dir" -mindepth 1 -maxdepth 1 -print0)

	return 0
}

remove_linked_skill_mirror() {
	local target_dir entry

	target_dir="$1"

	while IFS= read -r -d "" entry; do
		if [ -L "$entry" ]; then
			rm -f "$entry"
		elif [ -d "$entry" ]; then
			rmdir "$entry"
		fi
	done < <(find "$target_dir" -mindepth 1 -depth -print0)

	rmdir "$target_dir"
}

link_managed_skill_dir() {
	local source_dir target_dir display_path target_link

	source_dir="$1"
	target_dir="$2"
	display_path="$3"

	if [ -L "$target_dir" ]; then
		target_link="$(readlink "$target_dir" 2>/dev/null || true)"
		if [ "$target_link" != "$source_dir" ]; then
			echo "Warning: $target_dir is a symlink, skipping..."
			return 0
		fi
	elif [ -d "$target_dir" ] && is_linked_skill_mirror "$target_dir" "$source_dir"; then
		remove_linked_skill_mirror "$target_dir"
	elif [ -e "$target_dir" ]; then
		echo "Warning: $target_dir exists and is not a managed skill symlink, skipping..."
		return 0
	fi

	ln -snf "$source_dir" "$target_dir"
	echo "Linked $display_path"
}

link_dotfiles_runtime() {
	local repo_root dotfiles_root common_dir platform_dir agents_skills agent_skill_root
	local skill_source skill_name skill_target
	local rel source target prefix source_dir target_prefix target_rel layer stale_link
	local state_dir manifest_file manifest_tmp previous_rel
	declare -A sources=()
	declare -A agent_skill_sources=()
	declare -A current_targets=()
	local -a layers=()

	repo_root="$(find_repo_root || true)"
	if [ -z "$repo_root" ]; then
		echo "Dotfiles repo not found. Set NIXOS_CONFIG_ROOT to override automatic discovery."
		return 0
	fi

	dotfiles_root="$repo_root/dotfiles"
	common_dir="$dotfiles_root/common"
	platform_dir="$dotfiles_root/$platform"

	if [ -d "$common_dir" ]; then
		layers+=("$common_dir:")
	fi

	if [ -d "$platform_dir" ]; then
		layers+=("$platform_dir:")
	fi

	if [ "${#layers[@]}" -eq 0 ]; then
		echo "No dotfiles found to link."
		return 0
	fi

	for layer in "${layers[@]}"; do
		source_dir="${layer%%:*}"
		target_prefix="${layer#*:}"

		while IFS= read -r -d "" file; do
			prefix="$source_dir/"
			rel="${file#"$prefix"}"
			if [ -n "$target_prefix" ]; then
				target_rel="$target_prefix/$rel"
			else
				target_rel="$rel"
			fi
			sources["$target_rel"]="$file"
			current_targets["$target_rel"]=1
		done < <(find "$source_dir" -type f ! -name ".gitkeep" ! -path "$source_dir/.agents/skills/*" -print0)

		agent_skill_root="$source_dir/.agents/skills"
		if [ -d "$agent_skill_root" ]; then
			while IFS= read -r -d "" skill_source; do
				skill_name="$(basename "$skill_source")"
				if [ "$skill_name" = ".system" ]; then
					continue
				fi
				agent_skill_sources["$skill_name"]="$skill_source"
				current_targets[".agents/skills/$skill_name"]=1
			done < <(find "$agent_skill_root" -mindepth 1 -maxdepth 1 -type d -print0)
		fi
	done

	state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/link-dotfiles"
	manifest_file="$state_dir/manifest.$platform"
	manifest_tmp="$manifest_file.tmp"

	if [ -f "$manifest_file" ]; then
		while IFS= read -r previous_rel; do
			[ -n "$previous_rel" ] || continue
			if [ -z "${current_targets["$previous_rel"]+x}" ]; then
				stale_link="$HOME/$previous_rel"
				if [ -L "$stale_link" ]; then
					source="$(readlink "$stale_link" 2>/dev/null || true)"
					case "$source" in
					"$repo_root"/dotfiles/* | "$repo_root"/omarchy/config/*)
						rm -f "$stale_link"
						echo "Removed stale link ${stale_link#"$HOME"/}"
						;;
					esac
				fi
			fi
		done <"$manifest_file"
	fi

	echo "Processing ${#sources[@]} dotfile entries from $repo_root..."

	while IFS= read -r target_rel; do
		source="${sources["$target_rel"]}"
		target="$HOME/$target_rel"

		mkdir -p "$(dirname "$target")"
		if [ -e "$target" ] && [ ! -L "$target" ]; then
			echo "Warning: $target exists and is not a symlink, skipping..."
		else
			ln -snf "$source" "$target"
			echo "Linked $target_rel"
		fi
	done < <(printf '%s\n' "${!sources[@]}" | LC_ALL=C sort)

	agents_skills="$HOME/.agents/skills"
	if [ -e "$agents_skills" ] && [ ! -d "$agents_skills" ]; then
		echo "Warning: $agents_skills exists and is not a directory, skipping custom skill links..."
	else
		mkdir -p "$agents_skills"

		while IFS= read -r skill_name; do
			[ -n "$skill_name" ] || continue
			skill_source="${agent_skill_sources["$skill_name"]}"
			skill_target="$agents_skills/$skill_name"
			link_managed_skill_dir "$skill_source" "$skill_target" ".agents/skills/$skill_name -> ${skill_source#"$repo_root"/}"
		done < <(printf '%s\n' "${!agent_skill_sources[@]}" | LC_ALL=C sort)
	fi

	mkdir -p "$state_dir"
	printf '%s\n' "${!current_targets[@]}" | LC_ALL=C sort >"$manifest_tmp"
	mv "$manifest_tmp" "$manifest_file"
}

link_dotfiles_runtime
