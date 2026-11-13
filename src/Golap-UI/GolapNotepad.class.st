Class {
	#name : 'GolapNotepad',
	#superclass : 'SpPresenter',
	#instVars : [
		'sourceText',
		'preview',
		'clipList',
		'clipPreview',
		'notebook',
		'exportButton',
		'closeButton'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'operations' }
GolapNotepad >> addClip: aGolapClip [

	self note addClip: aGolapClip.
	self updatePages
]

{ #category : 'operations' }
GolapNotepad >> appendClip: aGolapClip [

	self note appendClip: aGolapClip.
	self updatePages
]

{ #category : 'layout' }
GolapNotepad >> clipsPage [

	^ SpBoxLayout newVertical
		  add: clipList;
		  add: clipPreview height: 400;
		  yourself
]

{ #category : 'initialization' }
GolapNotepad >> close [

	self window ifNotNil: #close
]

{ #category : 'layout' }
GolapNotepad >> defaultLayout [

	<script: 'self new open'>
	^ SpBoxLayout newHorizontal
		  add: notebook;
		  yourself
]

{ #category : 'operations' }
GolapNotepad >> export [

	self alert: '未実装'
]

{ #category : 'initialization' }
GolapNotepad >> initializePresenters [

	super initializePresenters.
	sourceText := self newText
		              whenTextChangedDo: [ self sourceTextChanged ];
		              yourself.
	preview := self instantiate: GolapMicrodownPresenter.
	clipList := self newTable
		            beResizable;
		            addColumn: (SpStringTableColumn title: 'ID' evaluated: [ :clip | clip id ]) beNotSortable;
		            addColumn: (SpStringTableColumn title: 'キャプション' evaluated: [ :clip | clip caption ]) beNotSortable;
		            addColumn:
			            (SpStringTableColumn title: '作成時刻' evaluated: [ :clip | clip timestamp epiceaBrowsersAsString ]) beSortable;
		            whenSelectedItemChangedDo: [ self updateClipPreview ];
		            yourself.
	clipPreview := self newImage
		               autoScale: true;
		               yourself.
	notebook := self newNotebook
		            addPageTitle: 'プレビュー' provider: [
				            SpPresenter new
					            layout: self previewPage;
					            yourself ];
		            addPageTitle: '編集' provider: [ sourceText ];
		            addPageTitle: 'クリップ' provider: [
			            SpPresenter new
				            layout: self clipsPage;
				            yourself ];
		            whenSelectedPageChangedDo: [ self updatePages ];
		            yourself.
	exportButton := self newButton
		                label: 'エキスポート';
		                action: [ self export ];
		                yourself
]

{ #category : 'initialization' }
GolapNotepad >> initializeWindow: aSpWindowPresenter [

	super initializeWindow: aSpWindowPresenter.
	aSpWindowPresenter
		title: 'ノート';
		initialExtent: 600 @ self currentWorld extent y;
		initialPosition: 0 @ 20.
	aSpWindowPresenter whenOpenedDo: [ self updatePages ]
]

{ #category : 'accessing' }
GolapNotepad >> note [

	^ GolapNote current
]

{ #category : 'layout' }
GolapNotepad >> previewPage [

	^ SpBoxLayout newVertical
		  add: preview;
		  add: exportButton expand: false;
		  yourself
]

{ #category : 'operations' }
GolapNotepad >> save [

	self alert: '未実装'
]

{ #category : 'updating' }
GolapNotepad >> sourceTextChanged [

	self note string: sourceText text
]

{ #category : 'updating' }
GolapNotepad >> updateClipList [

	| selection |
	selection := clipList selectedItem.
	clipList items: self note clips.
	(clipList items includes: selection) ifTrue: [ clipList selectItem: selection ]
]

{ #category : 'updating' }
GolapNotepad >> updateClipPreview [

	clipPreview image: (clipList selectedItem ifNotNil: [ :clip | clip image ])
]

{ #category : 'updating' }
GolapNotepad >> updatePages [

	sourceText isDisplayed ifTrue: [ self updateSourceText ].
	preview isDisplayed ifTrue: [ self updatePreview ].
	clipList isDisplayed ifTrue: [ self updateClipList ].
	clipPreview isDisplayed ifTrue: [ self updateClipPreview ]
]

{ #category : 'updating' }
GolapNotepad >> updatePreview [

	preview documentFromString: self note string.
	preview withAdapterDo: [ :a | a widgetDo: [ :w | w scrollToEndOfText ] ]
]

{ #category : 'updating' }
GolapNotepad >> updateSourceText [

	| newSource |
	(newSource := self note string) ~= sourceText text ifTrue: [
			sourceText text: newSource.
			sourceText withAdapterDo: [ :a | a widgetDo: [ :w | w scrollToEndOfText ] ] ]
]
