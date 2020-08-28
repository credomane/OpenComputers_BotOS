function os.sleep(timeout)
    checkArg(1, timeout, "number", "nil")
    local deadline = computer.uptime() + (timeout or 0)
    repeat
        local signal = table.pack(computer.pullSignal(0))
        -- there might not be any signal
        if signal.n > 0 then
            -- push the signal back in queue for the system to use it
            computer.pushSignal(table.unpack(signal, 1, signal.n))
        end
    until computer.uptime() >= deadline
end

return true
