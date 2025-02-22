Extension { #name : 'SpMorphicMenuButtonAdapter' }

{ #category : '*Golap-UI' }
SpMorphicMenuButtonAdapter >> newButton [

	^ PluggableButtonMorph
		  on: self
		  getState: nil
		  action: #action
		  label: #label
		  icon: #defaultIcon
		  menu: nil
]
