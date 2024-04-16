Class {
	#name : #GolapVertexAverageEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexAverageEvaluator >> name [

	^ 'average ' , golapModel edgeEvaluator name
]

{ #category : #evaluating }
GolapVertexAverageEvaluator >> value: aGolapVertex [

	^ (self valuesAtEdgesOfVertex: aGolapVertex)
		  ifNotEmpty: #average
		  ifEmpty: [ 0 ]
]
