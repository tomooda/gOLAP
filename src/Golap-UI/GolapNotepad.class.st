Class {
	#name : 'GolapNotepad',
	#superclass : 'SpPresenter',
	#traits : 'TGolapSnapshotablePresenter',
	#classTraits : 'TGolapSnapshotablePresenter classTrait',
	#instVars : [
		'sourceText',
		'preview',
		'notebook',
		'exportButton',
		'closeButton',
		'previewPage'
	],
	#category : 'Golap-UI-Notepad',
	#package : 'Golap-UI',
	#tag : 'Notepad'
}

{ #category : 'layout' }
GolapNotepad >> defaultLayout [

	<script: 'self new open'>
	^ SpBoxLayout newVertical
		  add: notebook;
		  add: (SpBoxLayout newHorizontal
				   hAlignEnd;
				   add: exportButton expand: false;
				   add: closeButton expand: false;
				   yourself)
		  expand: false;
		  yourself
]

{ #category : 'operations' }
GolapNotepad >> export [

	self alert: '未実装'
]

{ #category : 'initialization' }
GolapNotepad >> initializePresenters [

	super initializePresenters.
	sourceText := self newText.
	preview := self instantiate: GolapMicrodownPresenter.
	previewPage := self newNotebookPage
		               title: '清書';
		               presenterProvider: [ preview ];
		               yourself.
	notebook := self newNotebook
		            addPageTitle: 'ノート' provider: [ sourceText ];
		            addPage: previewPage;
		            whenSelectedPageChangedDo: [ notebook selectedPage = previewPage ifTrue: [ self updatePreview ] ];
		            yourself.
	closeButton := self newButton
		               label: '閉じる';
		               action: [ self close ];
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
		initialPosition: 0 @ 20
]

{ #category : 'operations' }
GolapNotepad >> save [

	self alert: '未実装'
]

{ #category : 'updating' }
GolapNotepad >> updatePreview [

	preview documentFromString: sourceText text
]
