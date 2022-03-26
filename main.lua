function love.load()
  wall1 = {x1 = 300, y1 = 700, x2 = 300, y2 = 500}
  wall2 = {x1 = 300, y1 = 300, x2 = 700, y2 = 300}
  rocket = {x = 20, y = 20, img = love.graphics.newImage("img/rocket.png")}
  fuel = {x = love.math.random(50, 850), y = love.math.random(50, 850), img = love.graphics.newImage("img/fuel.png")}
  chr = {x = 800, y = 500, img = love.graphics.newImage("img/chr.png")}
  chr.BBcircle = {x = chr.x, y = chr.y, r = 30}
  enemy = {x = 50, y = 50, img = love.graphics.newImage("img/enemy1.png")}
  enemy.BBcircle = {x = enemy.x, y = enemy.y, r = 30}

  obstacles = {wall1, wall2}
 
  target = {x = love.math.random(50, 850), y = love.math.random(50, 850)}

end

function love.update(dt)

  windowWidth = love.graphics.getWidth()
  windowHeight = love.graphics.getHeight()

  chr.originX = chr.img:getWidth() / 2
  chr.originY = chr.img:getHeight() / 2
  enemy.originX = enemy.img:getWidth() / 2
  enemy.originY = enemy.img:getHeight() / 2
  fuel.originX = fuel.img:getWidth() / 2
  fuel.originY = fuel.img:getHeight() / 2

  moveEnemy(dt)

  moveCharacter(chr, dt)
end

function love.draw()
  love.graphics.setColor(1,1,1)
  
  love.graphics.setLineWidth(1)

  love.graphics.setColor(1,1,1)
  love.graphics.draw(chr.img, chr.x, chr.y, 0, 0.2, 0.2, chr.originX, chr.originY)
  
  love.graphics.draw(enemy.img, enemy.x, enemy.y, 0, 0.2, 0.2, enemy.originX, enemy.originY)
  love.graphics.draw(fuel.img, fuel.x, fuel.y, 0, 0.2, 0.2, fuel.originX, fuel.originY)
  love.graphics.draw(rocket.img, rocket.x, rocket.y, 0, 0.5, 0.5)

 
  love.graphics.setLineWidth(10)
  love.graphics.line(wall1.x1, wall1.y1, wall1.x2, wall1.y2)
  love.graphics.line(wall2.x1, wall2.y1, wall2.x2, wall2.y2)

end

function enemyOnTarget()
  if math.abs(enemy.x - target.x) < 10 and math.abs(enemy.y - target.y) < 10 then
    return true
  else
    return false
  end
end

function moveEnemy(dt)
  local lastX = enemy.x
  local lastY = enemy.y
  if not robotHides() then
    getEnemyNewTarget(chr.x, chr.y)
  end

  enemyTargetAngle = math.atan2(target.y - enemy.y, target.x - enemy.x)

  enemy_cos = math.cos(enemyTargetAngle)
  enemy_sin = math.sin(enemyTargetAngle)
  enemy.x = enemy.x + 50 * enemy_cos * dt
  enemy.y = enemy.y + 50 * enemy_sin * dt
  updateBBcircle(enemy)

  if enemyOnTarget() then
    getEnemyNewTarget()
  end

  if checkWallsCollision(enemy) then
    enemy.x = lastX
    enemy.y = lastY
    getEnemyNewTarget()
  end
end

function moveCharacter(character, dt)
  local lastX = character.x
  local lastY = character.y
  if love.keyboard.isDown("up") then
    character.y = character.y - 50 * dt
    updateBBcircle(character)
  end
  if love.keyboard.isDown("down") then
    character.y = character.y + 50 * dt
    updateBBcircle(character)
  end
  if love.keyboard.isDown("left") then
    character.x = character.x - 50 * dt
    updateBBcircle(character)
  end
  if love.keyboard.isDown("right") then
    character.x = character.x + 50 * dt
    updateBBcircle(character)
  end

  if checkWallsCollision(character) then
    character.x = lastX
    character.y = lastY
  end
end

function updateBBcircle(character)
  character.BBcircle.x = character.x
  character.BBcircle.y = character.y
end


function checkWallsCollision(movingObject)
  if movingObject.x > windowWidth then
    return true
  end
  if movingObject.x < 0 then
    return true
  end
  if movingObject.y > windowHeight then
    return true
  end
  if movingObject.y < 0 then
    return true
  end

  -- obstacles collision detection
  if circleLine(movingObject.BBcircle, wall1) or circleLine(movingObject.BBcircle, wall2) then
    return true
  end
end

function robotHides()
  line1 = {x1 = chr.x, y1 = chr.y, x2 = enemy.x, y2 = enemy.y}
  line2 = wall1
  line3 = wall2
  return lineLineCollision(line1, line2) or lineLineCollision(line1, line3)
end


function getEnemyNewTarget(x, y)
  if not x then x = love.math.random(50, windowWidth) end
  if not y then y = love.math.random(50, windowHeight) end

  target.x = x
  target.y = y
end

-- collision detection circle - line
function circleLine(circle, line)
  local end1 = pointCircle(line.x1, line.y1, circle.x, circle.y, circle.r)
  local end2 = pointCircle(line.x2, line.y2, circle.x, circle.y, circle.r)
  
  
  
  local lineLength = math.dist(line.x1, line.y1, line.x2, line.y2)
  
  -- dot product for line - circle
  local dot = (((circle.x - line.x1) * (line.x2 - line.x1)) + ((circle.y - line.y1) * (line.y2 - line.y1))) / lineLength^2
  local closestX = line.x1 + (dot * (line.x2 - line.x1))
  local closestY = line.y1 + (dot * (line.y2 - line.y1))
  
  local circleLineDist = math.dist(circle.x, circle.y, closestX, closestY)
  
  if end1 or end2 then
    return true
  end
  
  
  if not pointLine(closestX, closestY, line) then
    return false
  end
    
  if circleLineDist < 40 then
    return true
  end
  

end


function pointLine(pointX, pointY, line)
  --get length between circle and lineend1
  pointLineEnd1Length = math.dist(pointX, pointY, line.x1, line.y1)
  
  --get length between circle and lineend2
  pointLineEnd2Length = math.dist(pointX, pointY, line.x2, line.y2)
  
  --get line length
  lineLength = math.dist(line.x1, line.y1, line.x2, line.y2)
  
  -- check for collision
  if pointLineEnd1Length + pointLineEnd2Length > lineLength - 10 and pointLineEnd1Length + pointLineEnd2Length < lineLength + 10 then
    return true
  else
    return false
  end
end


-- returns the distance between two circles
function math.dist(x1, y1, x2, y2)
  return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

function pointCircle(px, py, cx, cy, r)
  dist = math.dist(px, py, cx, cy)
  if dist < r then
    return true
  else
    return false
  end
end


function lineLineCollision(line1, line2)

  -- line 1 point 1
  x1 = line1.x1
  y1 = line1.y1

  -- line 1 point 2
  x2 = line1.x2
  y2 = line1.y2
  
  -- line 2 pont 1
  x3 = line2.x1
  y3 = line2.y1

  -- line 2 point 2
  x4 = line2.x2
  y4 = line2.y2

  ua = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))
  ub = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1))

  if (ua >= 0 and ub <= 1 and ub >= 0 and ua <= 1) then
    return true
  end
end
