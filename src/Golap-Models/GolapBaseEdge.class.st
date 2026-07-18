Class {
	#name : 'GolapBaseEdge',
	#superclass : 'Object',
	#instVars : [
		'node1',
		'node2',
		'data'
	],
	#category : 'Golap-Models-Base-Graph',
	#package : 'Golap-Models',
	#tag : 'Base-Graph'
}

{ #category : 'instance creation' }
GolapBaseEdge class >> node1: aString node2: anotherString data: aDictionary [

	^ self new
		  node1: aString;
		  node2: anotherString;
		  data: aDictionary;
		  yourself
]

{ #category : 'arithmetics' }
GolapBaseEdge >> - aGolapBaseEdge [

	| diff |
	diff := self copy.
	diff data ifNotNil: [ :diffData |
			aGolapBaseEdge data ifNotNil: [ :subtrahendData |
					subtrahendData keysAndValuesDo: [ :key :subtrahend |
							subtrahend isNumber ifTrue: [
								diffData
									at: key
									put: (diffData at: key ifAbsent: [ 0 ]) - subtrahend ] ] ] ].
	^ diff
]

{ #category : 'accessing' }
GolapBaseEdge >> data [

	^ data
]

{ #category : 'accessing' }
GolapBaseEdge >> data: aDataSeries [

	data := aDataSeries
]

{ #category : 'accessing' }
GolapBaseEdge >> key [

	^ node1 < node2
		  ifTrue: [
				  {
					  node1.
					  node2 } ]
		  ifFalse: [
				  {
					  node2.
					  node1 } ]
]

{ #category : 'arithmetics' }
GolapBaseEdge >> negated [

	| negative |
	negative := self shallowCopy.
	negative data: (negative data collect: [ :value |
			 value isNumber ifTrue: [ value negated ] ]).
	^ negative
]

{ #category : 'accessing' }
GolapBaseEdge >> node1 [

	^ node1
]

{ #category : 'accessing' }
GolapBaseEdge >> node1: aString [

	node1 := aString asString
]

{ #category : 'accessing' }
GolapBaseEdge >> node2 [

	^ node2
]

{ #category : 'accessing' }
GolapBaseEdge >> node2: aString [

	node2 := aString asString
]

{ #category : 'copying' }
GolapBaseEdge >> postCopy [

	super postCopy.
	data := data copy
]
