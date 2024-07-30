Class {
	#name : 'GolapWeightedAverageDataAggregator',
	#superclass : 'GolapDataAggregator',
	#instVars : [
		'column',
		'weightColumn'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapWeightedAverageDataAggregator class >> column: aString weightColumn: anotherString [

	^ self new
		  column: aString;
		  weightColumn: anotherString;
		  yourself
]

{ #category : 'instance creation' }
GolapWeightedAverageDataAggregator class >> fromSubtag: anArray [

	^ self column: anArray first weightColumn: anArray second
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator class >> tag [

	^ 'weighted-average'
]

{ #category : 'comparing' }
GolapWeightedAverageDataAggregator >> = anObject [

	^ self class = anObject class and: [
		  column = anObject column and: [
			  weightColumn = anObject weightColumn ] ]
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator >> column [

	^ column
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator >> column: aString [

	column := aString
]

{ #category : 'comparing' }
GolapWeightedAverageDataAggregator >> hash [

	^ (self class hash bitXor: column hash) bitXor: weightColumn hash
]

{ #category : 'printing' }
GolapWeightedAverageDataAggregator >> printOn: aStream [

	super printOn: aStream.
	aStream nextPut: $(.
	column printOn: aStream.
	aStream nextPut: $,.
	weightColumn printOn: aStream.
	aStream nextPut: $)
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator >> subtag [

	^ {
		  self column.
		  self weightColumn }
]

{ #category : 'evaluating' }
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
	^ self column -> (weightSum abs > 1.0e-8
		   ifTrue: [ sum / weightSum ]
		   ifFalse: [ 0 ])
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator >> weightColumn [

	^ weightColumn
]

{ #category : 'accessing' }
GolapWeightedAverageDataAggregator >> weightColumn: aString [

	weightColumn := aString
]
