-- Prevent Telegram from stealing focus on new messages
hl.window_rule({ name = "telegram-1", match = { class = "org.telegram.desktop" }, focus_on_activate = false })
