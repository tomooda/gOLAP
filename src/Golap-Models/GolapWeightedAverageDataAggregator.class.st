Class {
	#name : #GolapWeightedAverageDataAggregator,
	#superclass : #GolapDataAggregator,
	#instVars : [
		'column',
		'weightColumn'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapWeightedAverageDataAggregator class >> column: aString weightColumn: anotherString [

	^ self new
		  column: aString;
		  weightColumn: anotherString;
		  yourself
]

{ #category : #accessing }
GolapWeightedAverageDataAggregator >> column [

	^ column
]

{ #category : #accessing }
GolapWeightedAverageDataAggregator >> column: aString [

	column := aString
]

{ #category : #evaluating }
GolapWeightedAverageDataAggregator >> value: aCollectionOfDataSeries [

	| sum weightSum |
	sum := 0.
	weightSum := 0.
	aCollectionOfDataSeries do: [ :data |
		data at: column ifPresent: [ :value |
			value isNumber ifTrue: [
				data at: weightColumn ifPresent: [ :weight |
					sum := value * weight + sum.
					weightSum := weight + weightSum ] ] ] ].
	^ weightSum abs > 1.0e-8
		  ifTrue: [ sum / weightSum ]
		  ifFalse: [ 0 ]
]

{ #category : #accessing }
GolapWeightedAverageDataAggregator >> weightColumn [

	^ weightColumn
]

{ #category : #accessing }
GolapWeightedAverageDataAggregator >> weightColumn: aString [

	weightColumn := aString
]
