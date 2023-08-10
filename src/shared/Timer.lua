local RunService = game:GetService("RunService")

local Timer = {}
Timer.__index = Timer

function Timer.new(length)
	local self = setmetatable({}, Timer)
	
	self.remaining = length
	self.length = length
	self.running = false

    self._connection = RunService.Heartbeat:Connect(function(delta)
        if self.running then
            self.remaining = math.max(self.remaining - delta, 0)

            if self.remaining == 0 then
                self:Stop()
            end
        end
    end)
	
	return self
end

function Timer:Start(t)
	assert(not self.running, "You can only start a timer while it is stopped")

    self.remaining = t or self.length
    self.running = true
end

function Timer:Stop()
	assert(self.running, "You can only stop a timer while it is running")

	self.running = false
end

function Timer:Destroy()
	self._connection:Disconnect()
end

return Timer