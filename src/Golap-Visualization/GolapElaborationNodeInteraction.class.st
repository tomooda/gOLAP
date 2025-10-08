Class {
	#name : 'GolapElaborationNodeInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-Visualization-Elaboration',
	#package : 'Golap-Visualization',
	#tag : 'Elaboration'
}

{ #category : 'hooks' }
GolapElaborationNodeInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseLeftClick send: #processMouseLeftClick: to: self;
		when: RSMouseRightClick send: #processMouseRightClick: to: self
]

{ #category : 'accessing' }
GolapElaborationNodeInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapElaborationNodeInteraction >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter
]

{ #category : 'event processing' }
GolapElaborationNodeInteraction >> processMouseLeftClick: evt [

	presenter golapDo: [ :golap |
			evt shape model ifNotNil: [ :node |
				(node isKindOf: GolapNode) ifTrue: [ golap toggleSelection: node ] ] ]
]

{ #category : 'event processing' }
GolapElaborationNodeInteraction >> processMouseRightClick: evt [

	(evt shape model isKindOf: GolapNode) ifTrue: [
			presenter golapDo: [ :golap |
				(golap globalImageMenu: evt shape model) openWithSpecAtPointer ] ]
]

{ #category : 'rendering' }
GolapElaborationNodeInteraction >> renderLegendOn: legend [

	legend
		text: 'アイテムをクリック' description: 'アイテムを選択/選択解除する';
		text: 'アイテム上で右クリック' description: '商品メニュー'
]
