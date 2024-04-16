Class {
	#name : #GolapVertexEvaluator,
	#superclass : #Object,
	#instVars : [
		'golapModel'
	],
	#category : #'Golap-Models-Evaluator'
}

{ #category : #testing }
GolapVertexEvaluator class >> isAbstract [

	^ self = GolapVertexEvaluator
]

{ #category : #'instance creation' }
GolapVertexEvaluator class >> on: aGolapModel [

	^ self new
		  golapModel: aGolapModel;
		  yourself
]

{ #category : #converting }
GolapVertexEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : #sorting }
GolapVertexEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : #sorting }
GolapVertexEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : #accessing }
GolapVertexEvaluator >> golapModel [

	^ golapModel
]

{ #category : #accessing }
GolapVertexEvaluator >> golapModel: aGolapModel [

	golapModel := aGolapModel
]

{ #category : #accessing }
GolapVertexEvaluator >> name [

	^ self subclassResponsibility
]

{ #category : #evaluating }
GolapVertexEvaluator >> value: aGolapVertex [

	^ self subclassResponsibility
]

{ #category : #private }
GolapVertexEvaluator >> valuesAtEdgesOfVertex: aGolapVertex [

	^ Array streamContents: [ :stream |
		  self
			  valuesAtEdgesOfVertex: aGolapVertex
			  do: [ :value | stream nextPut: value ] ]
]

{ #category : #private }
GolapVertexEvaluator >> valuesAtEdgesOfVertex: aGolapVertex do: aBlock [

	aGolapVertex edgesDo: [ :edge |
		(golapModel valueAtEdge: edge) ifNotNil: aBlock ]
]
