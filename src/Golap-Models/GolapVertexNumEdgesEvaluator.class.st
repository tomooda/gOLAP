Class {
	#name : #GolapVertexNumEdgesEvaluator,
	#superclass : #GolapVertexEvaluator,
	#category : #'Golap-Models-Evaluator'
}

{ #category : #'instance creation' }
GolapVertexNumEdgesEvaluator class >> fromJSON: aDictionary [

	^ aDictionary at: self tag ifPresent: [ self new ] ifAbsent: [ nil ]
]

{ #category : #accessing }
GolapVertexNumEdgesEvaluator class >> tag [

	^ 'degree'
]

{ #category : #accessing }
GolapVertexNumEdgesEvaluator >> name [

	^ '関連数 (degree)'
]

{ #category : #accessing }
GolapVertexNumEdgesEvaluator >> subtag [

	^ true
]

{ #category : #evaluating }
GolapVertexNumEdgesEvaluator >> value: aGolapVertex [

	^ aGolapVertex numberOfEdges
]
