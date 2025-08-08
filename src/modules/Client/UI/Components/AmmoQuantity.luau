local require = require(script.Parent.loader).load(script)

local React = require("react")

export type AmmoQuantityProps = {
	ammo: number,
}

return function(props: AmmoQuantityProps)
	return React.createElement("TextLabel", {
		Size = UDim2.fromScale(1, 0.1),
		TextScaled = true,
		Text = props.ammo,
	})
end
