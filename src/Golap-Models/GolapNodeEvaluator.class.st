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

{ #category : 'accessing' }
GolapNodeEvaluator class >> tag [

	^ self subclassResponsibility
]

{ #category : 'converting' }
GolapNodeEvaluator >> asJSON [

	^ { (self tag -> self subtag) } asOrderedDictionary
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

{ #category : 'evaluating' }
GolapNodeEvaluator >> graph: aGolapModel [

	^ [ :node | self value: node graph: aGolapModel ]
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
GolapNodeEvaluator >> value: aGolapNode graph: aGolapModel [

	^ self subclassResponsibility
]
