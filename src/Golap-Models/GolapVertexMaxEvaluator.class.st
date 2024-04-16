Class {
	#name : #GolapVertexMaxEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexMaxEvaluator >> name [

	^ 'max ' , golapModel edgeEvaluator name
]

{ #category : #evaluating }
GolapVertexMaxEvaluator >> value: aGolapVertex [

	^ (self valuesAtEdgesOfVertex: aGolapVertex)
		  ifNotEmpty: #max
		  ifEmpty: [ 0 ]
]
