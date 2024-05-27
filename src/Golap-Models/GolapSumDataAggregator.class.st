Class {
	#name : 'GolapSumDataAggregator',
	#superclass : 'GolapDataAggregator',
	#instVars : [
		'column'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapSumDataAggregator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : 'comparing' }
GolapSumDataAggregator >> = anObject [

	^ self class = anObject class and: [ column = anObject column ]
]

{ #category : 'accessing' }
GolapSumDataAggregator >> column [

	^ column
]

{ #category : 'accessing' }
GolapSumDataAggregator >> column: aString [

	column := aString
]

{ #category : 'comparing' }
GolapSumDataAggregator >> hash [

	^ self class hash bitXor: column hash
]

{ #category : 'printing' }
GolapSumDataAggregator >> printOn: aStream [
	super printOn: aStream.
	aStream nextPut: $(.
	column printOn: aStream.
	aStream nextPut: $)
]

{ #category : 'evaluating' }
GolapSumDataAggregator >> value: aCollectionOfDataSeries [

	| sum |
	sum := 0.
	aCollectionOfDataSeries do: [ :data |
		data
			at: column
			ifPresent: [ :value |
			value isNumber ifTrue: [ sum := sum + value ] ] ].
	^ self column -> sum
]
