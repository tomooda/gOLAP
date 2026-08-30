Class {
	#name : 'GolapHEBChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#instVars : [
		'builder',
		'attributeDropList'
	],
	#category : 'Golap-Visualization-HEB',
	#package : 'Golap-Visualization',
	#tag : 'HEB'
}

{ #category : 'layout' }
GolapHEBChartPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   vAlignCenter;
				   add: '分類に使う属性' expand: false;
				   add: attributeDropList expand: false)
		  expand: false;
		  add: roassal
]

{ #category : 'updating' }
GolapHEBChartPresenter >> ensureAttributes [

	attributeDropList items size < 2 ifTrue: [ self updateAttributeDropList ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> golapChanged [

	self updateAttributeDropList.
	^ super golapChanged
]

{ #category : 'initialization' }
GolapHEBChartPresenter >> initializePresenters [

	super initializePresenters.
	attributeDropList := self newDropList
		                 display: [ :item | item ifNil: '-- なし --' ];
		                 items: { nil };
		                 selectFirst;
		                 whenSelectedItemChangedDo: [ self selectedAttributeChanged ];
		                 yourself
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderBaseHierarchy [

	| arcWidth |
	arcWidth := golap model nodes size.
	builder := RSHierarchicalEdgeBundleBuilder new.
	builder constantWidthStrategy
		centerWidth: arcWidth;
		arcWidth: arcWidth.
	builder
		container: self canvas;
		sliceColor: [ :slice |
				slice model isLeaf
					ifTrue: [ self colorForNode: (golap model nodeAt: slice model id) ]
					ifFalse: [ Color transparent ] ];
		explore: tree using: [ :t | t trees ];
		build
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> selectedAttribute [

	^ attributeDropList selectedItem
]

{ #category : 'updating' }
GolapHEBChartPresenter >> selectedAttributeChanged [

	self updateTree.
	self updateCanvas
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateAttributeDropList [

	(golap itemInfoRetriever ifNotNil: #attributeNames) ifNotNil: [ :names |
			| selection |
			selection := attributeDropList selectedItem.
			attributeDropList items: { nil } , names.
			(attributeDropList items includes: selection) ifTrue: [ attributeDropList selectItem: selection ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateCanvas [

	self ensureAttributes.
	self isDisplayed ifTrue: [
			self critical: [
					self ensureTree.
					self canvas shapes do: [ :shape |
							(shape model isKindOf: GolapEdge) ifTrue: [
									((golap includesSelection: shape model node1) or: [ golap includesSelection: shape model node2 ]) ifTrue: [
											shape
												color: (shape color alpha: 1.0);
												pushFront ] ] ].
					self zoomToFit ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateTree [

	self golapModelDo: [ :golapModel |
			| categories nodes modelMap gap |
			nodes := golap nodes reject: #isIsolated.
			self selectedAttribute
				ifNotNil: [ :attribute |
						categories := Dictionary new.
						GolapProgressDialog new
							title: '分類情報取得中…';
							informUserDuring: [ :progress |
									(golap itemInfoRetriever productDataAt: attribute forAll: nodes interim: [ :p | progress progressPercent: p * 100.0 ])
										keysAndValuesDo: [ :id :category | (categories at: category ifAbsentPut: [ OrderedCollection new ]) add: id ].
									self tree: (GolapHierarchicalClusteringNode withAll: (categories associations collect: [ :assoc |
																  | category ids |
																  category := assoc key.
																  ids := assoc value.
																  GolapHierarchicalClusteringNode withAll:
																		  (ids collect: [ :id | GolapHierarchicalClusteringLeaf id: id score: 1 ]) ])) ] ]
				ifNil: [
						self tree:
							(GolapHierarchicalClusteringNode withAll: (nodes collect: [ :node | GolapHierarchicalClusteringLeaf id: node id score: 1 ])) ].
			modelMap := Dictionary new.
			tree leavesDo: [ :leaf | modelMap at: leaf id put: leaf ].
			self canvas shapes copy do: #remove.
			self renderBaseHierarchy.
			self canvas shapes do: [ :shape |
					((shape model isKindOf: GolapHierarchicalClusteringTree) and: [ shape model isLeaf ]) ifTrue: [
							| color position label |
							color := self colorForNode: (golap model nodeAt: shape model id).
							gap := shape externalRadius * (shape alphaAngle - shape betaAngle) abs * Float pi / 180.0.
							(shape externalRadius - shape innerRadius) abs > gap ifTrue: [
									shape externalRadius: shape innerRadius + gap.
									gap := shape externalRadius * (shape alphaAngle - shape betaAngle) abs * Float pi / 180.0 ].
							position := shape centroid: gap * 0.5 + 4.
							label := RSLabel new text: (golap model nodeAt: shape model id) name.
							label
								position: label width / 2.0 @ 0;
								color: shape color;
								scaleBy: 0.4 * gap / label height;
								position: position + (position * (label width * 0.5 + (gap * 0.5) / position r));
								rotateByRadians: position theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0).
							self canvas addShape: label ] ].
			golapModel edgesDo: [ :edge |
					(golapModel normalizedValueAtEdge: edge) ifNotNil: [ :edgeValue |
							(golap colorForEdge: edge) ifNotNil: [ :color |
									modelMap at: edge node1 id ifPresent: [ :node1 |
											modelMap at: edge node2 id ifPresent: [ :node2 |
													builder addEdgeBetween: node1 and: node2 do: [ :bspline |
															bspline
																model: edge;
																width: edgeValue * gap * 0.5 + 1;
																color: color;
																capRound ] ] ] ] ] ] ]
]
