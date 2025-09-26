Class {
	#name : 'GolapOverviewNodeInteraction',
	#superclass : 'RSAbstractControlCanvasInteraction',
	#instVars : [
		'presenter'
	],
	#category : 'Golap-UI-Overview',
	#package : 'Golap-UI',
	#tag : 'Overview'
}

{ #category : 'hooks' }
GolapOverviewNodeInteraction >> onShape: aCanvas [

	aCanvas
		when: RSMouseLeftClick send: #processMouseLeftClick: to: self;
		when: RSMouseRightClick send: #processMouseRightClick: to: self
]

{ #category : 'accessing' }
GolapOverviewNodeInteraction >> presenter [

	^ presenter
]

{ #category : 'accessing' }
GolapOverviewNodeInteraction >> presenter: aGolapOverviewPresenter [

	presenter := aGolapOverviewPresenter
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> processMouseLeftClick: evt [

	presenter golapDo: [ :golap |
			evt shape model ifNotNil: [ :node |
				(node isKindOf: GolapNode) ifTrue: [ golap toggleSelection: node ] ] ]
]

{ #category : 'event processing' }
GolapOverviewNodeInteraction >> processMouseRightClick: evt [

	(evt shape model isKindOf: GolapNode) ifTrue: [
			presenter golapDo: [ :golap |
				(golap globalImageMenu: evt shape model) openWithSpecAtPointer ] ]
]

{ #category : 'rendering' }
GolapOverviewNodeInteraction >> renderLegendOn: legend [

	legend
		text: 'アイテムをクリック' description: 'アイテムを選択する';
		text: 'アイテム上で右クリック' description: '商品メニュー'
]
