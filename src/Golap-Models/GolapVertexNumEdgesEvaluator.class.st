Class {
	#name : #GolapVertexNumEdgesEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #accessing }
GolapVertexNumEdgesEvaluator >> name [

	^ 'degree'
]

{ #category : #evaluating }
GolapVertexNumEdgesEvaluator >> value: aGolapVertex [

	^ aGolapVertex numberOfEdges
]
