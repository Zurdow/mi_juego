function love.load()
    sheet = love.graphics.newImage("sheet.png")
    nave = love.graphics.newQuad(112,791,112,75, sheet:getDimensions())
    roca = love.graphics.newQuad(327,548,98,96, sheet:getDimensions())

    jugador = {
        x = 0,
        y = 250,
        ancho = 70,
        largo = 70,
        velocidad = 500,
        vidas = 3
    }
    obstaculos = {}
    tiempoCrearObstaculo = 0
    puntuacion = 0
    record = 0
    velocidadBase = 500
    tiempoPreparacion = 0
    gameOver = false

    estadoJuego = "menu"  -- Estado inicial del juego

    -- Definir botones del menú
    botones = {
        jugar = {x = love.graphics.getWidth() / 2 - 50, y = love.graphics.getHeight() / 2, ancho = 100, largo = 30, texto = "Jugar"},
        salir = {x = love.graphics.getWidth() / 2 - 50, y = love.graphics.getHeight() / 2 + 40, ancho = 100, largo = 30, texto = "Salir"}
    }
end

function love.update(dt)

     if estadoJuego == "menu" then
        return 
    end
    if tiempoPreparacion > 0 then
        tiempoPreparacion = tiempoPreparacion - dt
        if jugador.vidas == 0 then
            gameOver = true
        end
        return
    end

    if gameOver then
        if love.keyboard.isDown("return") then
            reiniciarJuego()
        end
    end

    -- Mover el jugador
    if love.keyboard.isDown("left", "a") then
        jugador.x = jugador.x - jugador.velocidad * dt
    end

    if love.keyboard.isDown("right", "d") then
        jugador.x = jugador.x + jugador.velocidad * dt
    end

    if love.keyboard.isDown("up", "w") then
        jugador.y = jugador.y - jugador.velocidad * dt
    end

    if love.keyboard.isDown("down", "s") then
        jugador.y = jugador.y + jugador.velocidad * dt
    end

    -- Crear nuevos obstáculos cada cierto tiempo
    tiempoCrearObstaculo = tiempoCrearObstaculo - dt
    if tiempoCrearObstaculo <= 0 then
        tiempoCrearObstaculo = 0.75 -- Crear un obstáculo cada segundo
        local obstaculo = {
            x = love.graphics.getWidth(),
            y = math.random(0, love.graphics.getHeight() - 50),
            ancho = 58,
            largo = 56,
            velocidad = velocidadBase + math.floor(puntuacion / 10) * 50
        }
        table.insert(obstaculos, obstaculo)
    end

    for i, obstaculo in ipairs(obstaculos) do
        obstaculo.x = obstaculo.x - obstaculo.velocidad * dt
    end

    for i = #obstaculos, 1, -1 do
        if obstaculos[i].x + obstaculos[i].ancho < 0 then
            table.remove(obstaculos, i)
            puntuacion = puntuacion + 1
        end
    end

    -- Comprobar colisiones
    for _, obstaculo in ipairs(obstaculos) do
        if verificarChoque(jugador, obstaculo) then
            jugador.vidas = jugador.vidas - 1
            jugador.x = 0
            jugador.y = 250
            tiempoPreparacion = 3
            obstaculos = {}
            tiempoCrearObstaculo = 0
            if jugador.vidas == 0 then
                record = math.max(record, puntuacion)
            end
            break
        end
    end
end

function love.draw()
    
    if estadoJuego == "menu" then
        dibujarMenu()
    else
        love.graphics.draw(sheet, nave, jugador.x, jugador.y, math.pi / 2, 1, 1, 50, 100)

        for i, obstaculo in ipairs(obstaculos) do
            love.graphics.draw(sheet, roca, obstaculo.x, obstaculo.y)
        end

        love.graphics.print("Vidas: " .. jugador.vidas, 10, 10)
        love.graphics.print("Puntuación: " .. puntuacion, 10, 30)
        love.graphics.print("Récord: " .. record, 10, 50)

        if tiempoPreparacion > 0 and jugador.vidas > 0 then
            love.graphics.print("Prepárate: " .. math.ceil(tiempoPreparacion), love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2)
        end

        if gameOver then
            love.graphics.print("Game Over", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 20)
            love.graphics.print("Puntuación: " .. puntuacion, love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2)
            love.graphics.print("Presiona Enter para reiniciar", love.graphics.getWidth() / 2 - 100, love.graphics.getHeight() / 2 + 20)
        end
    end
end

function verificarChoque(a, b)
    return a.x < b.x + b.ancho and
           b.x < a.x + a.ancho and
           a.y < b.y + b.largo and
           b.y < a.y + a.largo
end

function reiniciarJuego()
    jugador.x = 0
    jugador.y = 250
    jugador.vidas = 3
    jugador.velocidad = 500
    puntuacion = 0
    obstaculos = {}
    tiempoCrearObstaculo = 0
    tiempoPreparacion = 0
    gameOver = false
end
    function dibujarMenu()
        love.graphics.print("Supervivencia Espacial", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 100)
        love.graphics.print("Autor: Jose Castillo, C.I: 30.276.873", love.graphics.getWidth() / 2 - 50, love.graphics.getHeight() / 2 - 70)
        for nombre, boton in pairs(botones) do
            love.graphics.rectangle("line", boton.x, boton.y, boton.ancho, boton.largo)
            love.graphics.print(boton.texto, boton.x + 10, boton.y + 5)
        end
    end
    function love.mousepressed(x, y, button, istouch, presses)
        if button == 1 and estadoJuego == "menu" then
            for nombre, boton in pairs(botones) do
                if x > boton.x and x < boton.x + boton.ancho and y > boton.y and y < boton.y + boton.largo then
                if nombre == "jugar" then
                    estadoJuego = "playing"
                elseif nombre == "salir" then
                    love.event.quit()
                end
            end
        end
    end
end