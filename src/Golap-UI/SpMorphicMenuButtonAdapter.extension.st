Extension { #name : 'SpMorphicMenuButtonAdapter' }

{ #category : '*Golap-UI' }
SpMorphicMenuButtonAdapter >> action [

	self presenter menu ifNotNil: [ :aValuable |
			aValuable value ifNotNil: [ :aMenu |
					aMenu owner: self presenter.
					aMenu openWithSpecAtPointer ] ].

	self widget ifNotNil: [ :m | m takeKeyboardFocus ]
]

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
