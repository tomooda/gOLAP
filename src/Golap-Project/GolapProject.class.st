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

	<worldMenu>
	<golapMenu>
	(aBuilder item: #GolapProject)
		label: 'プロジェクト';
		order: 10;
		parent: #Golap;
		with: [
				(aBuilder item: #GolapOpenProjectFile)
					label: 'プロジェクトを開く...';
					iconName: #open;
					parent: #GolapProject;
					order: 20;
					target: self;
					selector: #open;
					enabled: self current projectFile isNil;
					help: 'プロジェクトファイルを開いて、グラフ分析状態を復元します。'.
				(aBuilder item: #GolapSaveProjectFile)
					label: 'プロジェクトを保存する...';
					iconName: #save;
					parent: #GolapProject;
					order: 21;
					enabled: true;
					target: self;
					selector: #save;
					help: 'グラフ分析状態をプロジェクトファイルに保存します。'.
				(aBuilder item: #GolapCloseProject)
					label: 'プロジェクトを閉じる...';
					iconName: #close;
					parent: #GolapProject;
					order: 80;
					enabled: self current projectFile notNil;
					target: self;
					selector: #quit;
					help: 'グラフ分析を閉じてプロジェクトを閉じます。' ]
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

	self golapWindowsDo: [ :window | window presenter forceClose ]
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

	self currentWorld taskbars do: [ :taskbar |
			taskbar submorphs do: [ :m1 |
					m1 model ifNotNil: [ :m2 |
							m2 model ifNotNil: [ :m3 |
									m3 presenter ifNotNil: [ :p |
										(p respondsTo: #asJSON) ifTrue: [ aBlock value: m3 ] ] ] ] ] ]
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
						  self load.
						  self updateMenubar ] ]
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

	(self
		 confirmYesNoCancel: 'プロジェクトを保存しますか？'
		 title: 'プロジェクト ' , (self projectName ifNil: [ 'なし' ])) ifNotNil: [
			:ans |
			ans ifTrue: [ self save ].
			self closeAll.
			self projectFile: nil.
			self updateMenubar ]
]

{ #category : 'operations' }
GolapProject >> save [

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
	^ dialog cancelled
		  ifTrue: [ nil ]
		  ifFalse: [
				  dialog selectedEntry ifNotNil: [ :ref |
						  projectFile := ref.
						  self store.
						  self updateMenubar ] ]
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
