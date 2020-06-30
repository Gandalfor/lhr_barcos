RegisterServerEvent('elrp:buyboat')
AddEventHandler( 'elrp:buyboat', function ( args )

    local _src   = source
    local _price = args['Price']
    local _level = args['Level']
    local _model = args['Model']

    TriggerEvent('vorp:getCharacter', _src, function(user)
        u_identifier = user.identifier
        --u_level = user.getLevel()
        u_charid = 0
        u_money = user.money
    end)

    if u_money <= _price then
        TriggerClientEvent( 'UI:DrawNotification', _src, Config.NoMoney )
        return
    end


    TriggerEvent("vorp:removeMoney", _src, 0, _price)

    exports.ghmattimysql:execute( "SELECT * FROM boates WHERE identifier = @identifier AND charid = @charid ", {
        ['identifier'] = u_identifier,
        ['charid'] = 0
    }, function(result)
        if #result > 0 then
            local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['boat'] = _model }
            exports.ghmattimysql:executeSync("UPDATE boates SET boat = @boat WHERE identifier = @identifier AND charid = @charid ", Parameters)
            TriggerClientEvent( 'UI:DrawNotification', _src, '¡Has comprado un nuevo barco!' )
        else
            local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid, ['boat'] = _model }
            exports.ghmattimysql:executeSync("INSERT INTO boates ( `identifier`, `charid`, `boat` ) VALUES ( @identifier, @charid, @boat )", Parameters)
            TriggerClientEvent( 'UI:DrawNotification', _src, 'Has comprado un nuevo barco!' )
        end
    end)

end)

RegisterServerEvent( 'elrp:dropboat' )
AddEventHandler( 'elrp:dropboat', function ( )

    local _src = source

    TriggerEvent('vorp:getCharacter', _src, function(user)
        u_identifier = user.identifier
        u_charid = 0
    end)

    local Parameters = { ['identifier'] = u_identifier, ['charid'] = u_charid }
    local HasBoates = exports.ghmattimysql:executeSync( "SELECT * FROM boates WHERE identifier = @identifier AND charid = @charid ", Parameters )
     
    --if HasBoates ~= nil then  
    if HasBoates[1] then
        local boat = HasBoates[1].boat
        TriggerClientEvent("elrp:spawnBoat", _src, boat)
    end
--end

end )
