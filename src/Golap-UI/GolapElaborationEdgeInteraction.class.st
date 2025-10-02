Class {
	#name : 'GolapElaborationEdgeInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-UI-Elaboration',
	#package : 'Golap-UI',
	#tag : 'Elaboration'
}

{ #category : 'hooks' }
GolapElaborationEdgeInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseLeftClick send: #processMouseLeftClick: to: self;
		when: RSMouseRightClick send: #processMouseRightClick: to: self
]

{ #category : 'accessing' }
GolapElaborationEdgeInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapElaborationEdgeInteraction >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter
]

{ #category : 'event processing' }
GolapElaborationEdgeInteraction >> processMouseLeftClick: evt [

	presenter golapDo: [ :golap |
			evt shape model ifNotNil: [ :edge |
					(edge isKindOf: GolapEdge) ifTrue: [
							((golap includesSelection: edge node1) and: [
								 golap includesSelection: edge node2 ])
								ifTrue: [
										golap
											unselect: edge node1;
											unselect: edge node2 ]
								ifFalse: [
										golap
											select: edge node1;
											select: edge node2 ] ] ] ]
]

{ #category : 'event processing' }
GolapElaborationEdgeInteraction >> processMouseRightClick: evt [

	evt shape model ifNotNil: [ :edge |
			(edge isKindOf: GolapEdge) ifTrue: [
					presenter golapDo: [ :golap |
							(golap newMenu addGroup: [ :group |
									 group
										 addItem: [ :item |
												 item
													 name: edge node1 name;
													 subMenu: (golap globalImageMenu: edge node1) ];
										 addItem: [ :item |
												 item
													 name: edge node2 name;
													 subMenu: (golap globalImageMenu: edge node2) ] ])
								openWithSpecAtPointer ] ] ]
]

{ #category : 'rendering' }
GolapElaborationEdgeInteraction >> renderLegendOn: legend [

	legend
		text: '関連をクリック' description: '関連する両アイテムを選択/選択解除する';
		text: '関連上で右クリック' description: '関連する両アイテムの商品メニュー'
]
