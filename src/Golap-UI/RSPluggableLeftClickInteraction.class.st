Class {
	#name : 'RSPluggableLeftClickInteraction',
	#superclass : 'RSInteraction',
	#instVars : [
		'action'
	],
	#category : 'Golap-UI-Roassal3',
	#package : 'Golap-UI',
	#tag : 'Roassal3'
}

{ #category : 'accessing' }
RSPluggableLeftClickInteraction >> action [

	^ action
]

{ #category : 'accessing' }
RSPluggableLeftClickInteraction >> action: aBlock [

	action := aBlock
]

{ #category : 'hooks' }
RSPluggableLeftClickInteraction >> clicked: event [

	action cull: event cull: event shape cull: event canvas
]

{ #category : 'handling' }
RSPluggableLeftClickInteraction >> defaultAction [

	^ [ :event :shape :canvas |  ]
]

{ #category : 'initialization' }
RSPluggableLeftClickInteraction >> initialize [

	super initialize.
	action := self defaultAction
]

{ #category : 'hooks' }
RSPluggableLeftClickInteraction >> onShape: aShape [

	aShape when: RSMouseLeftClick send: #clicked: to: self
]
