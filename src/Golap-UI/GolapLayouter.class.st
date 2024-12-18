Class {
	#name : 'GolapLayouter',
	#superclass : 'Object',
	#instVars : [
		'overridesYWithFrequencyOrder',
		'overridesYWithFrequency',
		'model',
		'lockedNodes',
		'divisions'
	],
	#category : 'Golap-UI-Layouter',
	#package : 'Golap-UI',
	#tag : 'Layouter'
}

{ #category : 'instance creation' }
GolapLayouter class >> on: aGolapModel [
	^ self new
		model: aGolapModel;
		yourself
]

{ #category : 'accessing' }
GolapLayouter >> divisions [
	^ divisions ifNil: [ 1 ]
]

{ #category : 'initialization' }
GolapLayouter >> initialize [

	super initialize.
	overridesYWithFrequency := false.
	overridesYWithFrequencyOrder := false.
	lockedNodes := IdentitySet new.
	divisions := nil
]

{ #category : 'accessing' }
GolapLayouter >> layout [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapLayouter >> lockedNodes: anIdentitySetOfGolapNode [

	lockedNodes := anIdentitySetOfGolapNode
]

{ #category : 'accessing' }
GolapLayouter >> model [
	^ model
]

{ #category : 'accessing' }
GolapLayouter >> model: aGolapModel [

	model := aGolapModel
]

{ #category : 'layouting' }
GolapLayouter >> move: aGolapNode toX: aNumber y: anotherNumber [

	(lockedNodes includes: aGolapNode) ifFalse: [
		aGolapNode
			x: aNumber;
			y: anotherNumber ].
	^ aGolapNode
]

{ #category : 'layouting' }
GolapLayouter >> move: aGolapNode toY: aNumber [

	(lockedNodes includes: aGolapNode) ifFalse: [ aGolapNode y: aNumber ].
	^ aGolapNode
]

{ #category : 'accessing' }
GolapLayouter >> overridesYWithFrequency [
	^ overridesYWithFrequency = true
]

{ #category : 'accessing' }
GolapLayouter >> overridesYWithFrequency: aBoolean [
	overridesYWithFrequency := aBoolean = true
]

{ #category : 'accessing' }
GolapLayouter >> overridesYWithFrequencyOrder [
	^ overridesYWithFrequencyOrder = true
]

{ #category : 'accessing' }
GolapLayouter >> overridesYWithFrequencyOrder: aBoolean [
	overridesYWithFrequencyOrder := aBoolean = true
]
