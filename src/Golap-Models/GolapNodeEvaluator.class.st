Class {
	#name : 'GolapNodeEvaluator',
	#superclass : 'Object',
	#instVars : [
		'golapModel'
	],
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'instance creation' }
GolapNodeEvaluator class >> fromJSON: aDictionary [

	self allSubclassesDo: [ :subclass |
		subclass isAbstract not ifTrue: [
			(subclass fromJSON: aDictionary) ifNotNil: [ :evaluator |
				^ evaluator ] ] ].
	^ nil
]

{ #category : 'testing' }
GolapNodeEvaluator class >> isAbstract [

	^ self = GolapNodeEvaluator
]

{ #category : 'instance creation' }
GolapNodeEvaluator class >> on: aGolapModel [

	^ self new
		  golapModel: aGolapModel;
		  yourself
]

{ #category : 'accessing' }
GolapNodeEvaluator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapNodeEvaluator >> asJSON [
	^ { self tag -> self subtag }
]

{ #category : 'converting' }
GolapNodeEvaluator >> asSortFunction [

	^ PropertySortFunction property: self
]

{ #category : 'sorting' }
GolapNodeEvaluator >> ascending [

	^ self asSortFunction
]

{ #category : 'sorting' }
GolapNodeEvaluator >> descending [

	^ self asSortFunction reversed
]

{ #category : 'accessing' }
GolapNodeEvaluator >> golapModel [

	^ golapModel
]

{ #category : 'accessing' }
GolapNodeEvaluator >> golapModel: aGolapModel [

	golapModel := aGolapModel
]

{ #category : 'accessing' }
GolapNodeEvaluator >> name [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeEvaluator >> subtag [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
GolapNodeEvaluator >> tag [

	^ self class tag
]

{ #category : 'evaluating' }
GolapNodeEvaluator >> value: aGolapNode [

	^ self subclassResponsibility
]

{ #category : 'private' }
GolapNodeEvaluator >> valuesAtEdgesOfNode: aGolapNode [

	^ Array streamContents: [ :stream |
		  self
			  valuesAtNodeOfNode: aGolapNode
			  do: [ :value | stream nextPut: value ] ]
]

{ #category : 'private' }
GolapNodeEvaluator >> valuesAtNodeOfNode: aGolapNode do: aBlock [

	aGolapNode edgesDo: [ :edge |
		(golapModel valueAtEdge: edge) ifNotNil: aBlock ]
]
