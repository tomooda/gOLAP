Class {
	#name : 'GolapProject',
	#superclass : 'Object',
	#instVars : [
		'projectFile'
	],
	#classInstVars : [
		'current'
	],
	#category : 'Golap-UI-Snapshot',
	#package : 'Golap-UI',
	#tag : 'Snapshot'
}

{ #category : 'sole instance' }
GolapProject class >> current [

	^ current ifNil: [ current := self new ]
]

{ #category : 'menus' }
GolapProject class >> golapMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #GolapProject)
		label: 'プロジェクト';
		order: 0.5;
		with: [
				(aBuilder item: #'プロジェクトを開く...')
					parent: #GolapProject;
					order: 20;
					target: self;
					selector: #open;
					help: 'プロジェクトファイルを開いて、グラフ分析状態を復元します。'.
				(aBuilder item: #'プロジェクトを保存する...')
					parent: #GolapProject;
					order: 21;
					enabled: self current projectFile notNil;
					target: self;
					selector: #save;
					help: 'グラフ分析状態をプロジェクトファイルに保存します。' ]
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
GolapProject class >> save [

	self current save
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
									  stream nextPut: window asJSON ] ] ]
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
										(p respondsTo: #asJSON) ifTrue: [ aBlock value: p ] ] ] ] ] ]
]

{ #category : 'operations' }
GolapProject >> load [

	projectFile ifNotNil: [
			projectFile readStreamDo: [ :stream |
					(NeoJSONReader on: stream) next ifNotNil: [ :json |
							self golapWindowsDo: [ :presenter | presenter window close ].
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
						  projectFile := ref.
						  self load ] ]
]

{ #category : 'accessing' }
GolapProject >> projectFile [

	^ projectFile
]

{ #category : 'accessing' }
GolapProject >> projectFile: aFileReference [

	projectFile := aFileReference
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
						  self store ] ]
]

{ #category : 'operations' }
GolapProject >> store [

	projectFile ifNotNil: [
			self asJSON ifNotNil: [ :json |
					projectFile writeStreamDo: [ :stream |
							stream truncate.
							(NeoJSONWriter on: stream) nextPut: json ] ] ]
]
