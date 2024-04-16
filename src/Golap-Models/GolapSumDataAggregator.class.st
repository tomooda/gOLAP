Class {
	#name : #GolapSumDataAggregator,
	#superclass : #GolapDataAggregator,
	#instVars : [
		'column'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapSumDataAggregator class >> column: aString [

	^ self new
		  column: aString;
		  yourself
]

{ #category : #accessing }
GolapSumDataAggregator >> column [

	^ column
]

{ #category : #accessing }
GolapSumDataAggregator >> column: aString [

	column := aString
]

{ #category : #evaluating }
GolapSumDataAggregator >> value: aCollectionOfDataSeries [

	| sum |
	sum := 0.
	aCollectionOfDataSeries do: [ :data |
		data
			at: column
			ifPresent: [ :value |
			value isNumber ifTrue: [ sum := sum + value ] ] ].
	^ sum
]