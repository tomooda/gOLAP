Class {
	#name : #GolapVertexSumEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexSumEvaluator >> name [

	^ 'sum ' , golapModel edgeEvaluator name
]

{ #category : #evaluating }
GolapVertexSumEvaluator >> value: aGolapVertex [

	^ (self valuesAtEdgesOfVertex: aGolapVertex)
		  ifNotEmpty: #sum
		  ifEmpty: [ 0 ]
]
