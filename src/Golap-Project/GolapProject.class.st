Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#instVars : [
		'projectFile'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Golap-Project',
	#package : 'Golap-Project'
}

{ #category : 'sole instance' }
GolapProject class >> current [

	^ current ifNil: [ current := self new ]
]

{ #category : 'accessing' }
GolapProject class >> fileExtension [

	^ 'golap'
]

{ #category : 'menus' }
GolapProject class >> golapMenuOn: aBuilder [

	<golapMenu>
	(aBuilder item: #GolapOpenProjectFile)
		label: 'プロジェクトを開く...';
		iconName: #open;
		parent: #GolapFileMenu;
		order: 20;
		target: self;
		selector: #open;
		help: 'プロジェクトファイルを開いて、グラフ分析状態を復元します。'.
	(aBuilder item: #GolapSaveProjectFile)
		label: 'プロジェクトを保存する...';
		iconName: #save;
		parent: #GolapFileMenu;
		order: 21;
		target: self;
		selector: #save;
		help: 'グラフ分析状態をプロジェクトファイルに保存します。';
		withSeparatorAfter.
	(aBuilder item: #GolapCloseProject)
		label: '終了';
		iconName: #smallQuit;
		parent: #GolapFileMenu;
		order: 99;
		target: self;
		selector: #quit;
		help: 'gOLAPを終了します。'
]

{ #category : 'operations' }
GolapProject class >> open [

	self current open
]

{ #category : 'accessing' }
GolapProject class >> projectBaseDirectory [

	^ Golap golapDirectory
]

{ #category : 'operations' }
GolapProject class >> quit [

	self current quit
]

{ #category : 'operations' }
GolapProject class >> save [

	self current save
]

{ #category : 'ui requests' }
GolapProject >> application [

	^ SpApplication defaultApplication
]

{ #category : 'converting' }
GolapProject >> asJSON [

	^ Array streamContents: [ :stream |
			  | windows |
			  windows := self golapWindows.
			  SpProgressDialog new
				  title: '保存中...';
				  informUserDuring: [ :progress |
						  windows withIndexDo: [ :window :index |
									  progress
										  label: '保存中... ' , window title;
										  progressPercent: index * 100 // windows size.
									  stream nextPut: window presenter asJSON ] ] ]
]

{ #category : 'operations' }
GolapProject >> closeAll [

	self golapWindows ifEmpty: [ ^ self ].
	(self
		 confirmYesNoCancel: 'プロジェクトを保存しますか？'
		 title: 'プロジェクト ' , (self projectName ifNil: [ 'なし' ])) ifNotNil: [
			:ans |
			ans ifTrue: [ self save ].
			self golapWindowsDo: [ :window | window presenter forceClose ] ]
]

{ #category : 'ui requests' }
GolapProject >> confirm: aString title: anotherString [

	^ self application newConfirm
		  label: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'ui requests' }
GolapProject >> confirmYesNoCancel: aString title: anotherString [

	^ (GolapConfirmYesNoCancelDialog newApplication: self application)
		  label: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'converting' }
GolapProject >> fromJSON: anArray [

	| dialog |
	dialog := SpProgressDialog new.
	dialog
		title: '復元中...';
		informUserDuring: [ :progress |
				| widget |
				widget := dialog adapter widget.
				anArray withIndexDo: [ :json :index |
							progress progressPercent: index * 100 // anArray size.
							json at: 'class' ifPresent: [ :className |
										(TGolapSnapshotablePresenter users
											 detect: [ :class | class name asString = className ]
											 ifNone: [ nil ]) ifNotNil: [ :class |
												class fromJSON: json ] ] ] ]
]

{ #category : 'accessing' }
GolapProject >> golapWindows [

	^ Array streamContents: [ :stream |
		  self golapWindowsDo: [ :window | stream nextPut: window ] ]
]

{ #category : 'enumerating' }
GolapProject >> golapWindowsDo: aBlock [

	| presenterClasses |
	presenterClasses := TGolapSnapshotablePresenter users.
	self currentWorld taskbars do: [ :taskbar |
			taskbar submorphs do: [ :m1 |
					m1 model ifNotNil: [ :m2 |
							m2 model ifNotNil: [ :m3 |
									m3 presenter ifNotNil: [ :p |
										(presenterClasses includes: p class) ifTrue: [
											aBlock value: m3 ] ] ] ] ] ]
]

{ #category : 'operations' }
GolapProject >> load [

	projectFile ifNotNil: [
			projectFile readStreamDo: [ :stream |
					(NeoJSONReader on: stream) next ifNotNil: [ :json |
							self closeAll.
							self fromJSON: json ] ] ]
]

{ #category : 'operations' }
GolapProject >> open [

	| dialog |
	dialog := StOpenFilePresenter new.
	dialog
		title: 'プロジェクトを開く';
		extensions: #( 'golap' ).
	projectFile
		ifNotNil: [
				dialog
					defaultFolder: projectFile parent;
					selectFile: projectFile ]
		ifNil: [ dialog defaultFolder: self class projectBaseDirectory ].
	dialog openModal.
	^ dialog cancelled
		  ifTrue: [ nil ]
		  ifFalse: [
				  dialog selectedEntry ifNotNil: [ :ref |
						  self projectFile: ref.
						  self load ] ]
]

{ #category : 'accessing' }
GolapProject >> projectFile [

	^ projectFile
]

{ #category : 'accessing' }
GolapProject >> projectFile: aFileReference [

	projectFile := aFileReference.
	self updateWorldWindowTitle
]

{ #category : 'accessing' }
GolapProject >> projectName [

	^ projectFile ifNotNil: [
		  projectFile basenameWithoutExtension: self class fileExtension ]
]

{ #category : 'operations' }
GolapProject >> quit [

	self closeAll.
	self projectFile: nil.
	Smalltalk snapshot: false andQuit: true
]

{ #category : 'operations' }
GolapProject >> save [

	(self golapWindows notEmpty or: [
		 self confirm: '空のプロジェクトを保存しますか？' title: 'プロジェクト保存' ]) ifTrue: [
			| dialog |
			dialog := StSaveFilePresenter new.
			dialog
				title: 'プロジェクトを保存する';
				extensions: #( 'golap' ).
			projectFile
				ifNotNil: [
						dialog
							defaultFolder: projectFile parent;
							selectFile: projectFile ]
				ifNil: [ dialog defaultFolder: self class projectBaseDirectory ].
			dialog openModal.
			dialog cancelled ifFalse: [
					dialog selectedEntry ifNotNil: [ :ref |
							projectFile := ref.
							self store ] ] ]
]

{ #category : 'operations' }
GolapProject >> store [

	projectFile ifNotNil: [
			self asJSON ifNotNil: [ :json |
					projectFile writeStreamDo: [ :stream |
							stream truncate.
							(NeoJSONWriter on: stream)
								prettyPrint: true;
								nextPut: json ] ] ]
]

{ #category : 'updating' }
GolapProject >> updateMenubar [

	GolapMenubar reset
]

{ #category : 'updating' }
GolapProject >> updateWorldWindowTitle [

	self currentWorld worldState worldRenderer osWindow title:
		(self projectName ifNil: [ 'gOLAP' ])
]
