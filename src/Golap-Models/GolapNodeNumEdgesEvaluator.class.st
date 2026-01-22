Class {
	#name : 'GolapNodeNumEdgesEvaluator',
	#superclass : 'GolapNodeEvaluator',
	#category : 'Golap-Models-Evaluators',
	#package : 'Golap-Models',
	#tag : 'Evaluators'
}

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator class >> tag [

	^ 'degree'
]

{ #category : 'comparing' }
GolapNodeNumEdgesEvaluator >> = anObject [

	^ self class = anObject class
]

{ #category : 'comparing' }
GolapNodeNumEdgesEvaluator >> hash [

	^ self class hash
]

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator >> name [

	^ '関連数 (degree)'
]

{ #category : 'accessing' }
GolapNodeNumEdgesEvaluator >> subtag [

	^ true
]

{ #category : 'evaluating' }
GolapNodeNumEdgesEvaluator >> value: aGolapNode graph: aGolapModel [

	^ aGolapNode numberOfEdges
]
