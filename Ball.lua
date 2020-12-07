ball = Class{}

function ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.height = height
    self.width = width

    self.dx = math.random(2) == 1 and 100 or -100
    self.dy = math.random(-50, 50)
end

function ball:collide(box)
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end 
    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end 
    
    return true
end 

function ball:reset()
    
   self.x = virtual_width / 2 - 5
   self.y = virtual_height / 2 - 5
   self.dx = math.random(2) == 1 and 100 or -100
   self.dy = math.random(-50, 50)
   
end

function ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function ball: render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end