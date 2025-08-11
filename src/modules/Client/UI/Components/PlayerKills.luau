local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.React)

local require = require(script.Parent.loader).load(script)

return React.createElement("Frame", {
	Size = UDim2.fromScale(1, 1),
}, {
	React.createElement("TextLabel"),
})
