Class {
	#name : 'GolapHierarchicalClusteringPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'golap',
		'tree',
		'roassal'
	],
	#category : 'Golap-Visualization-Clustering',
	#package : 'Golap-Visualization',
	#tag : 'Clustering'
}

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> activateOnNotebookPage [
]

{ #category : 'snapshot' }
GolapHierarchicalClusteringPresenter >> asJSON [

	^ {  } asDictionary
]

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

{ #category : 'snapshot' }
GolapHierarchicalClusteringPresenter >> fromJSON: aDictionary [

	
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

{ #category : 'testing' }
GolapHierarchicalClusteringPresenter >> showsNode: aGolapNode [

	tree ifNotNil: [
		tree idsDo: [ :id | id = aGolapNode id ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'operations' }
GolapHierarchicalClusteringPresenter >> toggleSelection: aGolapNode [

	golap toggleSelection: aGolapNode
]

{ #category : 'operations' }
GolapHierarchicalClusteringPresenter >> toggleSelectionsAll: aCollectionOfGolapNode [

	(aCollectionOfGolapNode anySatisfy: [ :node |
		 (golap includesSelection: node) not ])
		ifTrue: [ golap selectAll: aCollectionOfGolapNode ]
		ifFalse: [ golap unselectAll: aCollectionOfGolapNode ]
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

	self updateCanvas.
	golap updateItemsList
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateCanvas [

	^ self subclassResponsibility
]

{ #category : 'updating' }
GolapHierarchicalClusteringPresenter >> updateNode [

	self isDisplayed ifTrue: [
			self canvas shapes do: [ :shape |
					(shape model isKindOf: GolapHierarchicalClusteringLeaf) ifTrue: [
						shape color:
							(self colorForNode: (golap model nodeAt: shape model id)) ].
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
					((shape model isKindOf: GolapHierarchicalClusteringLeaf) and: [
						 shape model id = aGolapNode id ]) ifTrue: [
						shape color:
							(self colorForNode: (golap model nodeAt: shape model id)) ].
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
GolapHierarchicalClusteringPresenter >> updatePhotoimage: shape [

	(golap model nodeAt: shape model id) photoimage ifNotNil: [
		:photoimage |
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
							  tree) removeAllBut: golap ids asSet) ] ] ] ]
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
