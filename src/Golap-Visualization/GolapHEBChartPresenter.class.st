Class {
	#name : 'GolapHEBChartPresenter',
	#superclass : 'GolapHierarchicalClusteringPresenter',
	#instVars : [
		'attributeDropList',
		'nodeCategories',
		'categoryNodes',
		'visibleNodes',
		'nodePositions',
		'categoryPositions'
	],
	#category : 'Golap-Visualization-HEB',
	#package : 'Golap-Visualization',
	#tag : 'HEB'
}

{ #category : 'enumerating' }
GolapHEBChartPresenter >> categoriesDo: aBlock [

	self ensureCategories.
	categoryNodes keysDo: aBlock
]

{ #category : 'enumerating' }
GolapHEBChartPresenter >> category: aString nodesDo: aBlock [

	self ensureCategories.
	categoryNodes at: aString ifPresent: [ :nodes | nodes do: aBlock ]
]

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
GolapHEBChartPresenter >> ensureCategories [

	(nodeCategories isNil or: [ categoryNodes isNil ]) ifTrue: [ self updateCategories ]
]

{ #category : 'private' }
GolapHEBChartPresenter >> evens: aSequenceableCollection [

	^ (2 to: aSequenceableCollection size by: 2) collect: [ :index | aSequenceableCollection at: index ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> flushCategories [

	nodeCategories := categoryNodes := visibleNodes := nodePositions := categoryPositions := nil
]

{ #category : 'updating' }
GolapHEBChartPresenter >> golapChanged [

	self updateAttributeDropList.
	self updateCanvas
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

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForCategory: aString [

	^ RSLabel new
		  text: aString;
		  color: Color gray;
		  yourself
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdge: pair [

	| node1 node2 category1 category2 |
	node1 := pair first.
	node2 := pair second.
	category1 := nodeCategories at: node1 ifAbsent: [ nil ].
	category2 := nodeCategories at: node2 ifAbsent: [ nil ].
	^ category1 = category2
		  ifTrue: [ self newShapeForEdgeBetween: node1 and: node2 category: category1 ]
		  ifFalse: [
				  self
					  newShapeForEdgeBetween: node1
					  category: category1
					  and: node2
					  category: category2 ]
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdgeBetween: node1 and: node2 category: category [

	| p1 p2 p3 |
	p1 := nodePositions at: node1 ifAbsent: [ ^ nil ].
	p2 := categoryPositions at: category ifAbsent: [ ^ nil ].
	p3 := nodePositions at: node2 ifAbsent: [ ^ nil ].
	^ RSUniformCubicBSpline new
		  controlPoints: {
				  p1.
				  p2.
				  p3 };
		  capRound;
		  yourself
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForEdgeBetween: node1 category: category1 and: node2 category: category2 [

	| p1 p2 p3 p4 |
	p1 := nodePositions at: node1 ifAbsent: [ ^ nil ].
	p2 := categoryPositions at: category1 ifAbsent: [ ^ nil ].
	p3 := categoryPositions at: category2 ifAbsent: [ ^ nil ].
	p4 := nodePositions at: node2 ifAbsent: [ ^ nil ].
	^ RSUniformCubicBSpline new
		  controlPoints: {
				  p1.
				  p2.
				  p3.
				  p4 };
		  capRound;
		  yourself
]

{ #category : 'instance creation' }
GolapHEBChartPresenter >> newShapeForNode: node [

	^ RSBox new
		  extent: 10 @ 10;
		  color: (self colorForNode: node);
		  yourself
]

{ #category : 'private' }
GolapHEBChartPresenter >> odds: aSequenceableCollection [

	^ (1 to: aSequenceableCollection size by: 2) collect: [ :index | aSequenceableCollection at: index ]
]

{ #category : 'private' }
GolapHEBChartPresenter >> peakCentered: aDescendingCollection [
	"self new peakCentered: #(10 9 8 7 6 5 4 3 2 1)"
	"self new peakCentered: #(9 8 7 6 5 4 3 2 1)"

	^ (self evens: aDescendingCollection) reversed , (self odds: aDescendingCollection)
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderEdgesIn: aCanvas [

	self ensureCategories.
	self golapModelDo: [ :golapModel |
			golapModel edgesDo: [ :edge |
					(self colorForEdge: edge) ifNotNil: [ :color |
							(self newShapeForEdge: edge key) ifNotNil: [ :shape |
									shape
										color: (color alpha: 0.5);
										width: (golapModel normalizedValueAtEdge: edge) * 10.
									aCanvas add: shape ] ] ] ]
]

{ #category : 'rendering' }
GolapHEBChartPresenter >> renderNodesIn: aCanvas [

	| radius theta delta newNodePositions newCategoryPositions |
	self ensureCategories.
	radius := 300.0.
	theta := 0.0.
	delta := Float pi * 2.0 / (visibleNodes size + categoryNodes size) asFloat.
	newNodePositions := Dictionary new.
	newCategoryPositions := Dictionary new.
	newCategoryPositions at: nil put: 0.0 @ 0.0.
	self categoriesDo: [ :category |
			| minTheta maxTheta |
			minTheta := maxTheta := theta.
			self category: category nodesDo: [ :node |
					(self newShapeForNode: node) ifNotNil: [ :shape |
							| position |
							position := Point r: radius theta: theta.
							shape
								rotateByRadians: position theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0);
								position: position.
							aCanvas add: shape.
							newNodePositions at: node put: position ].
					maxTheta := theta := theta + delta ].
			category
				ifNotNil: [
						(self newShapeForCategory: category) ifNotNil: [ :shape |
								| position |
								position := Point r: radius * 0.5 theta: minTheta + maxTheta * 0.5.
								shape
									rotateByRadians: position theta + (Float pi / 2.0) \\ Float pi - (Float pi / 2.0);
									position: position.
								aCanvas add: shape.
								newCategoryPositions at: category put: position ] ]
				ifNil: [ newCategoryPositions at: nil put: 0.0 @ 0.0 ].
			theta := theta + delta ].
	nodePositions := newNodePositions.
	categoryPositions := newCategoryPositions
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> selectedAttribute [

	^ attributeDropList selectedItem
]

{ #category : 'updating' }
GolapHEBChartPresenter >> selectedAttributeChanged [

	self flushCategories.
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

	self isDisplayed ifTrue: [
			self critical: [
					self ensureAttributes.
					self canvas shapes copy do: #remove.
					self
						renderNodesIn: self canvas;
						renderEdgesIn: self canvas ] ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateCategories [

	self golapModelDo: [ :golapModel |
			| nodeValues newCategoryNodes newNodeCategories |
			visibleNodes := golap nodes reject: #isIsolated.
			nodeValues := Dictionary new: visibleNodes size.
			visibleNodes do: [ :node | nodeValues at: node id put: ((golapModel normalizedValueAtNode: node) ifNil: [ 0.0 ]) ].
			newCategoryNodes := Dictionary new.
			newNodeCategories := Dictionary new.
			self selectedAttribute
				ifNotNil: [ :attribute |
						GolapProgressDialog new
							title: '分類情報取得中…';
							informUserDuring: [ :progress |
									(golap itemInfoRetriever
										 productDataAt: attribute
										 forAll: visibleNodes
										 interim: [ :p | progress progressPercent: p * 100.0 ]) keysAndValuesDo: [ :id :category |
												newNodeCategories at: id put: category.
												(newCategoryNodes at: category ifAbsentPut: [ OrderedCollection new ]) add: id ] ] ]
				ifNil: [
						newCategoryNodes at: nil put: visibleNodes asOrderedCollection.
						visibleNodes do: [ :node | newNodeCategories at: node put: nil ] ].
			nodeCategories := newNodeCategories.
			categoryNodes := (((newCategoryNodes associations collect: [ :assoc |
					                    assoc key -> (assoc value sorted: [ :node | nodeValues at: node ifAbsent: [ 0.0 ] ] descending) asArray
					                    -> (assoc value collect: [ :node | nodeValues at: node ifAbsent: [ 0.0 ] ]) sum ]) sorted:
				                   #value descending) collect: #key) asOrderedDictionary ]
]

{ #category : 'updating' }
GolapHEBChartPresenter >> updateTree [

	self flushCategories.
	self updateCanvas
]

{ #category : 'accessing' }
GolapHEBChartPresenter >> visibleNodes [

	visibleNodes ifNil: [ self updateCategories ].
	^ visibleNodes
]
