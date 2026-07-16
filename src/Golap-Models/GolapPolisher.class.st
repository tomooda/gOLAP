Class {
	#name : 'GolapPolisher',
	#superclass : 'Object',
	#instVars : [
		'fillerEdges',
		'burrEdges'
	],
	#category : 'Golap-Models-Analysis',
	#package : 'Golap-Models',
	#tag : 'Analysis'
}

{ #category : 'operations' }
GolapPolisher >> applyTo: aGolapModel [

	burrEdges do: [ :edge | edge remove ].
	fillerEdges do: [ :edge | edge attach ]
]

{ #category : 'enumerating' }
GolapPolisher >> atNode: aGolapNode edgesAndNodesDo: aBlock [

	aGolapNode edgesAndNodeDo: [ :edge :peer |
		(burrEdges includes: edge) ifFalse: [
			aBlock value: edge value: peer ] ].
	fillerEdges do: [ :edge |
			(edge peerOf: aGolapNode) ifNotNil: [ :peer |
				aBlock value: edge value: peer ] ]
]

{ #category : 'accessing' }
GolapPolisher >> burrEdges [

	^ burrEdges
]

{ #category : 'accessing' }
GolapPolisher >> fillerEdges [

	^ fillerEdges
]

{ #category : 'operations' }
GolapPolisher >> fit: aGolapModel fillerThreshold: fillerThreshold burrThreshold: burrThreshold minClusterSize: minClusterSize [

	| hop2peers edges newFillerEdges newBurrEdges |
	hop2peers := IdentityDictionary new.
	edges := IdentitySet new.
	newFillerEdges := IdentitySet new.
	newBurrEdges := IdentitySet new.
	aGolapModel nodesDo: [ :v1 |
			| peers |
			peers := hop2peers at: v1 put: IdentityDictionary new.
			self atNode: v1 edgesAndNodesDo: [ :e1 :v2 |
					edges add: e1.
					self atNode: v2 edgesAndNodesDo: [ :e2 :v3 |
							v1 id < v3 id ifTrue: [
								peers at: v3 put: (peers at: v3 ifAbsent: [ 0 ]) + 1 ] ] ] ].
	hop2peers keysAndValuesDo: [ :v1 :peersAndDups |
			peersAndDups keysAndValuesDo: [ :v2 :dups |
					(v1 ~~ v2 and: [ (self node: v1 hasEdgeTo: v2) not ]) ifTrue: [
							| v1NumEdges v2NumEdges denominator |
							v1NumEdges := self numberOfEdgesAtNode: v1.
							v2NumEdges := self numberOfEdgesAtNode: v2.
							denominator := v1NumEdges + v2NumEdges - dups.
							denominator > minClusterSize ifTrue: [
									dups asFloat / (v1NumEdges + v2NumEdges - dups) asFloat
									> fillerThreshold ifTrue: [
										newFillerEdges add: (GolapEdge on: nil between: v1 and: v2) ] ] ] ] ].
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
					 | v1NumEdges v2NumEdges dups denominator |
					 v1NumEdges := self numberOfEdgesAtNode: v1.
					 v2NumEdges := self numberOfEdgesAtNode: v2.

					 dups := peersAndDups at: v2.
					 denominator := v1NumEdges + v2NumEdges - dups.
					 denominator > minClusterSize and: [
							 dups asFloat / (v1NumEdges + v2NumEdges - dups) asFloat
							 < burrThreshold ] ]) ifTrue: [ newBurrEdges add: edge ] ].
	newFillerEdges removeAllSuchThat: [ :edge |
		(newBurrEdges remove: edge ifAbsent: [ nil ]) notNil ].
	newFillerEdges do: [ :edge |
		burrEdges remove: edge ifAbsent: [ fillerEdges add: edge ] ].
	newBurrEdges do: [ :edge |
		fillerEdges remove: edge ifAbsent: [ burrEdges add: edge ] ].
	^ newFillerEdges notEmpty or: [ newBurrEdges notEmpty ]
]

{ #category : 'operations' }
GolapPolisher >> fitToConverge: aGolapModel fillerThreshold: fillerThreshold burrThreshold: burrThreshold minClusterSize: minClusterSize [

	[
		self
			fit: aGolapModel
			fillerThreshold: fillerThreshold
			burrThreshold: burrThreshold
			minClusterSize: minClusterSize ] whileTrue
]

{ #category : 'initialization' }
GolapPolisher >> initialize [

	burrEdges := IdentitySet new.
	fillerEdges := IdentitySet new
]

{ #category : 'testing' }
GolapPolisher >> node: aGolapNode1 hasEdgeTo: aGolapNode2 [

	(fillerEdges anySatisfy: [ :edge |
		 edge hasNode: aGolapNode1 and: aGolapNode2 ]) ifTrue: [ ^ true ].
	(aGolapNode1 edgeTo: aGolapNode2) ifNotNil: [ :edge |
		^ (burrEdges includes: edge) not ].
	^ false
]

{ #category : 'accessing' }
GolapPolisher >> numberOfEdgesAtNode: aGolapNode [

	| numEdges |
	numEdges := aGolapNode numberOfEdges.
	fillerEdges do: [ :edge |
		(edge hasNode: aGolapNode) ifTrue: [ numEdges := numEdges + 1 ] ].
	burrEdges do: [ :edge |
		(edge hasNode: aGolapNode) ifTrue: [ numEdges := numEdges - 1 ] ].
	^ numEdges
]

{ #category : 'accessing' }
GolapPolisher >> reset [

	burrEdges removeAll.
	fillerEdges removeAll
]
