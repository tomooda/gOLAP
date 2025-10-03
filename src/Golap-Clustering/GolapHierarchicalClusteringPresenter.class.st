Class {
	#name : 'GolapHierarchicalClusteringPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'tree',
		'roassal'
	],
	#category : 'Golap-Clustering-Core',
	#package : 'Golap-Clustering',
	#tag : 'Core'
}

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> canvas [

	^ roassal canvas
]

{ #category : 'accessing-colors' }
GolapHierarchicalClusteringPresenter >> colorForNode: aGolapNode [

	^ golap colorForNode: aGolapNode
]

{ #category : 'layout' }
GolapHierarchicalClusteringPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: roassal;
		  yourself
]

{ #category : 'private' }
GolapHierarchicalClusteringPresenter >> edgeColorForScore: aNumber [

	^ aNumber >= 0
		  ifTrue: [ Color black ]
		  ifFalse: [ Color red ]
]

{ #category : 'private' }
GolapHierarchicalClusteringPresenter >> edgeWidthForScore: aNumber [

	| denominator |
	denominator := tree score.
	^ denominator abs > 1.0e-8
		  ifTrue: [
		  ((tree size min: 50) * aNumber / denominator) abs max: 1.0 ]
		  ifFalse: [ 1.0 ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> golap [

	^ golap
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> golap: aGolap [

	golap := aGolap.
	golap announcer
		when: GolapModelUpdated send: #updateTree to: self;
		when: GolapViewUpdated send: #updateNode to: self.
	self golapChanged
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> golapChanged [

	golap model ifNotNil: [ self updateTree ]
]

{ #category : 'initialization' }
GolapHierarchicalClusteringPresenter >> initializePresenters [

	| controller |
	super initializePresenters.
	controller := RSCanvasController new.
	controller configuration
		shouldAnimateZoom: false;
		useBasicZoom.
	roassal := self newRoassal
		           canvas: RSCanvas new @ controller;
		           yourself
]

{ #category : 'private' }
GolapHierarchicalClusteringPresenter >> markerModelForNode: aGolapNode color: aColor [

	^ {
		  #marker.
		  aGolapNode.
		  aColor }
]

{ #category : 'private' }
GolapHierarchicalClusteringPresenter >> markerWidth [

	^ 10
]

{ #category : 'operations' }
GolapHierarchicalClusteringPresenter >> toggleSelection: aGolapNode [

	golap toggleSelection: aGolapNode.
	self updateNode: aGolapNode
]

{ #category : 'operations' }
GolapHierarchicalClusteringPresenter >> toggleSelectionsAll: aCollectionOfGolapNode [

	(aCollectionOfGolapNode anySatisfy: [ :node |
		 (golap includesSelection: node) not ])
		ifTrue: [ golap selectAll: aCollectionOfGolapNode ]
		ifFalse: [ golap unselectAll: aCollectionOfGolapNode ].
	self updateNode
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> tree [

	^ tree
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> tree: aGolapHierarchicalClusteringTree [

	tree := aGolapHierarchicalClusteringTree.
	self treeChanged
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> treeChanged [

	self updateCanvas
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateCanvas [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateNode [

	self isDisplayed ifTrue: [
			self canvas shapes do: [ :shape |
					(shape model respondsTo: #graphNode) ifTrue: [
						shape color: (self colorForNode: shape model graphNode) ].
					(shape model isArray and: [ shape model first = #marker ])
						ifTrue: [
								| v c |
								v := shape model second.
								c := shape model third.
								shape color: ((v hasMarker: c)
										 ifTrue: [ c ]
										 ifFalse: [ Color transparent ]) ] ].
			self canvas signalUpdate ]
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateNode: aGolapNode [

	self isDisplayed ifTrue: [
			self canvas shapes do: [ :shape |
					((shape model respondsTo: #graphNode) and: [
						 shape model graphNode == aGolapNode ]) ifTrue: [
						shape color: (self colorForNode: aGolapNode) ].
					(shape model isArray and: [
						 shape model first = #marker and: [
							 shape model second == aGolapNode ] ]) ifTrue: [
							| c |
							c := shape model third.
							shape color: ((aGolapNode hasMarker: c)
									 ifTrue: [ c ]
									 ifFalse: [ Color transparent ]) ] ].
			self canvas signalUpdate ]
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updatePhotoimage: shape [

	shape model graphNode photoimage ifNotNil: [ :photoimage |
		(shape schildren contains: [ :child | child model = #photoimage ])
			ifFalse: [
				shape canvas addShape: ((RSBitmap newFrom: photoimage)
						 model: #photoimage;
						 position:
							 (shape centroid: shape externalRadius - shape innerRadius / 2
									  + (golap allMarkerColors size * 10 + 20));
						 extent: (shape externalRadius
							  * ((shape alphaAngle - shape betaAngle) abs / 90.0 * 3.14)
								  min: shape externalRadius - shape innerRadius) asPoint;
						 yourself) ] ]
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateTree [

	self isDisplayed ifTrue: [
			self withAdapterDo: [ :a |
					a widgetDo: [ :w |
							w world ifNotNil: [
									self tree: (((GolapHierarchicalClustering on: golap model)
											  rank: 2;
											  rank: 4;
											  rank: 8;
											  rank: 16;
											  rank: 32;
											  rank: 64;
											  rank: 128;
											  rank: 256;
											  tree) removeAllBut: golap nodes asSet) ] ] ] ]
]

{ #category : 'accessing' }
GolapHierarchicalClusteringPresenter >> windowTitle [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> zoomToFit [

	self canvas
		zoomToFit;
		signalUpdate
]
