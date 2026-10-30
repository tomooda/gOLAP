Class {
	#name : 'GolapMorphicMicrodownAdapter',
	#superclass : 'MicMorphicTextAdapter',
	#category : 'Golap-Notepad-Microdown',
	#package : 'Golap-Notepad',
	#tag : 'Microdown'
}

{ #category : 'widget API' }
GolapMorphicMicrodownAdapter >> addExtraActionsTo: actionGroup [
		
	"override to add extra actions between user defined and edition"
]

{ #category : 'factory' }
GolapMorphicMicrodownAdapter >> buildWidget [

	| newWidget |
	newWidget := super buildWidget.
	newWidget
		getBackgroundColorSelector: #color;
		menuProvider: self selector: #codePaneMenu:shifted:.

	self composeOn: newWidget.
	self presenter whenDocumentChangedDo: [ :aDocument | self compose ].
	self presenter whenTextStylerChangedDo: [ :aStyler | self compose ].
	self presenter whenColorChangedDo: [ :color | self setColor: color ].
	^ newWidget
]

{ #category : 'widget API' }
GolapMorphicMicrodownAdapter >> codePaneMenu: aMenu shifted: shifted [

	| menuPresenter actionGroup |
	actionGroup := SpActionGroup new beRoot.

	self presenter internalActions ifNotNil: [ :group | actionGroup add: group beRoot ].
	self addExtraActionsTo: actionGroup.
	self presenter actions ifNotNil: [ :group | actionGroup add: group beRoot ].
	"self presenter hasEditionContextMenu ifTrue: [ actionGroup add: self presenter editionCommandsGroup beRoot ]."

	menuPresenter := self presenter newMenu.
	menuPresenter fillWith: actionGroup.

	^ SpBindings value: self model application adapterBindings during: [ menuPresenter value build ]
]

{ #category : 'composing' }
GolapMorphicMicrodownAdapter >> compose [

	self widgetDo: [ :w | self composeOn: w ]
]

{ #category : 'composing' }
GolapMorphicMicrodownAdapter >> composeOn: aWidget [

	self presenter document ifNil: [ ^ self ].
	self presenter text: ([
			 MicRichTextComposer new
				 textStyler: self presenter textStyler;
				 asRichText: self presenter document ]
			 on: GolapMicrodownPresenterRequest
			 do: [ :ex | ex resume: self presenter ])
]

{ #category : 'accessing' }
GolapMorphicMicrodownAdapter >> interactionModel [

	^ nil
]

{ #category : 'composing' }
GolapMorphicMicrodownAdapter >> recompose [

	self widgetDo: [ :w | self recomposeOn: w ]
]

{ #category : 'composing' }
GolapMorphicMicrodownAdapter >> recomposeOn: aWidget [

	self presenter document ifNil: [ ^ self ].
	self presenter setText: ([
			 MicRichTextComposer new
				 textStyler: self presenter textStyler;
				 asRichText: self presenter document ]
			 on: GolapMicrodownPresenterRequest
			 do: [ :ex | ex resume: self presenter ])
]

{ #category : 'presenter->morph' }
GolapMorphicMicrodownAdapter >> setColor: aColor [

	widget ifNotNil: [ widget backgroundColor: aColor ]
]

{ #category : 'presenter->morph' }
GolapMorphicMicrodownAdapter >> setText: aText to: aWidget [
	"called by presenter to set text in morph"

	scalingImageIndexes := (1 to: aText size)
		select: [ :idx |
			((aText at: idx) = Character home)
			and: [ (aText attributeAt: idx ofKind: MicScalingTextAnchor) notNil ] ].

	aWidget
		setText: aText;
		resetState
]
