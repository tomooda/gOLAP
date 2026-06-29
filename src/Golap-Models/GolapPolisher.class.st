Class {
	#name : 'GolapPolisher',
	#superclass : 'Object',
	#instVars : [
		'additionThreshold',
		'removalThreshold',
		'minClusterSize',
		'repeats'
	],
	#category : 'Golap-Models-Graph',
	#package : 'Golap-Models',
	#tag : 'Graph'
}

{ #category : 'accessing' }
GolapPolisher >> additionThreshold [

	^ additionThreshold
]

{ #category : 'accessing' }
GolapPolisher >> additionThreshold: aNumber [

	additionThreshold := aNumber
]

{ #category : 'applying' }
GolapPolisher >> applyTo: aGolapModel [

	(repeats = true
		 ifTrue: [ 100 ]
		 ifFalse: [ 1 ]) timesRepeat: [
			| changed hop2peers edges |
			changed := false.
			hop2peers := IdentityDictionary new.
			edges := IdentitySet new.
			aGolapModel nodesDo: [ :v1 |
					| peers |
					peers := hop2peers at: v1 put: IdentityDictionary new.
					v1 edgesAndNodeDo: [ :e1 :v2 |
							edges add: e1.
							v2 edgesAndNodeDo: [ :e2 :v3 |
									v1 id < v3 id ifTrue: [
										peers at: v3 put: (peers at: v3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
			hop2peers keysAndValuesDo: [ :v1 :peersAndDups |
					peersAndDups keysAndValuesDo: [ :v2 :dups |
							(v1 canHavePositivePolishEdge: v2) ifTrue: [
									| denominator |
									denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
									denominator > minClusterSize ifTrue: [
											dups asFloat
											/ (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
											> additionThreshold ifTrue: [
													changed := true.
													(aGolapModel removeNegativePolishEdgeBetween: v1 and: v2)
														ifNil: [
																| newEdge |
																newEdge := GolapEdge on: nil between: v1 and: v2.
																v1 addPositivePolishEdge: newEdge.
																v2 addPositivePolishEdge: newEdge.
																aGolapModel addPositivePolishEdge: newEdge ] ] ] ] ] ].
			edges do: [ :edge |
					| v1 v2 peersAndDups |
					edge node1 id <= edge node2 id
						ifTrue: [
								v1 := edge node1.
								v2 := edge node2 ]
						ifFalse: [
								v1 := edge node2.
								v2 := edge node1 ].
					peersAndDups := hop2peers at: v1.
					((peersAndDups includesKey: v2) and: [
							 | dups denominator |
							 dups := peersAndDups at: v2.
							 denominator := v1 numberOfEdges + v2 numberOfEdges - dups.
							 denominator > minClusterSize and: [
									 dups asFloat
									 / (v1 numberOfEdges + v2 numberOfEdges - dups) asFloat
									 < removalThreshold ] ]) ifTrue: [
							changed := true.
							(aGolapModel removePositivePolishEdgeBetween: v1 and: v2)
								ifNil: [
										v1 addNegativePolishEdge: edge.
										v2 addNegativePolishEdge: edge.
										aGolapModel addNegativePolishEdge: edge ] ] ].
			changed ifFalse: [ ^ self ] ]
]

{ #category : 'initialization' }
GolapPolisher >> initialize [

	super initialize.
	additionThreshold := 1.0.
	removalThreshold := 0.0.
	minClusterSize := 3.
	repeats := false
]

{ #category : 'accessing' }
GolapPolisher >> minClusterSize [

	^ minClusterSize
]

{ #category : 'accessing' }
GolapPolisher >> minClusterSize: anInteger [

	minClusterSize := anInteger
]

{ #category : 'accessing' }
GolapPolisher >> removalThreshold [

	^ removalThreshold
]

{ #category : 'accessing' }
GolapPolisher >> removalThreshold: aNumber [

	removalThreshold := aNumber
]

{ #category : 'accessing' }
GolapPolisher >> repeats [

	^ repeats
]

{ #category : 'accessing' }
GolapPolisher >> repeats: aBoolean [

	repeats := aBoolean
]
