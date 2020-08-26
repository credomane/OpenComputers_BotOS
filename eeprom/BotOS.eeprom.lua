--[[
    This is my custom EEPROM for booting BotOS. Please use the uglified file for flashing.
    Other EEPROM do NOT provided the required custom EEPROM functions to boot BotOS.

    Things this EEPROM does
     1. Load and parse data section
     2. If microcontroller check for and activate modem send gps location from data section
     3. full Boot or go back to sleep (data section dictates)
]]--


--Currently scrapped idea pending a rethinking.
--Squeezing in GPS, internet boot, modem mesh networking AND modem boot is proving hard all in eeprom. lol
