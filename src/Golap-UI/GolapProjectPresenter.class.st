Class {
	#name : 'GolapProjectPresenter',
	#superclass : 'SpPresenter',
	#instVars : [
		'projectList',
		'notepad',
		'addProjectButton',
		'renameProjectButton',
		'removeProjectButton',
		'saveProjectButton',
		'switchProjectButton',
		'golapNotebook',
		'leftToolbar',
		'rightToolbar'
	],
	#classVars : [
		'Current'
	],
	#category : 'Golap-UI-Project',
	#package : 'Golap-UI',
	#tag : 'Project'
}

{ #category : 'sole instance' }
GolapProjectPresenter class >> current [

	^ Current ifNil: [ Current := self new ]
]

{ #category : 'sole instance' }
GolapProjectPresenter class >> flushCurrent [

	<script>
	Current := nil
]

{ #category : 'menus' }
GolapProjectPresenter class >> golapMenuOn: aBuilder [

	<worldMenu>
	(aBuilder item: #GolapOpenProjectPresenter)
		label: 'gOLAP';
		iconName: #open;
		parent: #Golap;
		order: 0;
		target: self;
		selector: #open;
		help: 'プロジェクトリストを開きます。'
]

{ #category : 'operations' }
GolapProjectPresenter class >> open [

	<script: 'GolapProjectPresenter open'>
	| window |
	self current updateProjectList.
	window := self current window ifNil: [ self current asWindow ].
	window isOpen
		ifTrue: [ window activate ]
		ifFalse: [ window open maximize ]
]

{ #category : 'menus' }
GolapProjectPresenter class >> openFullScreen [

	<script>
	self current asWorldWindow
		title: 'gOLAP';
		open
]

{ #category : 'layout' }
GolapProjectPresenter >> _defaultLayout [

	^ SpPanedLayout newVertical
		  positionOfSlider: 0.25;
		  add: (SpBoxLayout newVertical
				   add: projectList expand: true;
				   add: (SpBoxLayout newHorizontal
						    add: addProjectButton expand: true;
						    add: renameProjectButton expand: true;
						    add: removeProjectButton expand: true;
						    yourself)
				   expand: false;
				   add: saveProjectButton expand: false;
				   add: switchProjectButton expand: false;
				   yourself);
		  add: (SpBoxLayout newVertical
				   add: (SpBoxLayout newHorizontal
						    hAlignCenter;
						    add: 'ノート' expand: false)
				   expand: false;
				   add: notepad;
				   yourself);
		  yourself
]

{ #category : 'operations' }
GolapProjectPresenter >> addClip: aGolapClip [

	notepad addClip: aGolapClip
]

{ #category : 'operations' }
GolapProjectPresenter >> addGolap: aGolap [

	| page |
	page := self newNotebookPage
		        title: aGolap windowTitle;
		        presenterProvider: [ aGolap ];
		        beCloseable;
		        yourself.
	golapNotebook
		addPage: page;
		selectPage: page
]

{ #category : 'operations' }
GolapProjectPresenter >> addProject [

	self confirmToSaveCurrentProject ifNotNil: [
			(self requestNewProject: '') ifNotNil: [ :project |
					self saveAsProject: project.
					self selectProject: project.
					project beCurrent.
					self
						updateProjectList;
						updateNotepad ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> alert: aString title: anotherString [

	(self application newAlert
		 message: aString;
		 title: anotherString;
		 asModalWindow)
		initialExtent: 500 @ 120;
		open
]

{ #category : 'operations' }
GolapProjectPresenter >> appendClip: aGolapClip [

	notepad appendClip: aGolapClip
]

{ #category : 'converting' }
GolapProjectPresenter >> asJSON [

	| json |
	json := Dictionary new.
	self toJSON: json.
	^ json
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirm: queryString title: titleString [

	^ self application newConfirm
		  title: titleString;
		  message: queryString;
		  openModal
]

{ #category : 'operations' }
GolapProjectPresenter >> confirmToSaveCurrentProject [

	^ self currentProject
		  ifDefault: [
				  ((self confirmYesNoCancel: '現在のプロジェクトを保存しますか？' title: '保存の確認') = true)
					  ifTrue: [ (self requestNewProject: '') ifNotNil: [ :project | self saveAsProject: project ] ];
					  yourself ]
		  otherwise: [ :current |
				  ((self confirmYesNoCancel: current projectName , 'を保存しますか？' title: '保存の確認') = true)
					  ifTrue: [ self saveAsProject: current ];
					  yourself ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> confirmYesNoCancel: aString title: anotherString [

	^ (GolapConfirmYesNoCancelDialog newApplication: self application)
		  message: aString;
		  title: anotherString;
		  openModal
]

{ #category : 'initialization' }
GolapProjectPresenter >> createLeftToolbar [

	^ self newToolbar
		  beBoth;
		  add: (self newToolbarButton
				   icon: (self iconNamed: #remote);
				   label: '新規クエリー';
				   help: 'gOLAPサーバーに接続してクエリを送信してグラフを開きます';
				   action: [ GolapNetworkClientPresenter open ];
				   yourself);
		  add: (self newToolbarButton
				   icon: (self iconNamed: #open);
				   label: '表ファイル';
				   help: '商品CSVファイルと関連CSVファイルを選択してグラフを開きます';
				   action: [ GolapCSVLauncher open ];
				   yourself);
		  yourself
]

{ #category : 'initialization' }
GolapProjectPresenter >> createRightToolbar [

	^ self newToolbar
		  beBoth;
		  add: (self newToolbarButton
				   icon: (self iconNamed: #configuration);
				   label: '設定';
				   help: 'gOLAPクライアントの設定画面を開きます';
				   action: [ Golap showSettingBrowser ];
				   yourself);
		  add: (self newToolbarButton
				   icon: (self iconNamed: #smallQuit);
				   label: '終了';
				   help: 'gOLAPクライアントを終了します';
				   action: [ GolapApplication quit ];
				   yourself);
		  yourself
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProject [

	^ GolapProject current
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectFile [

	^ self currentProject projectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> currentProjectName [

	^ self currentProject projectName
]

{ #category : 'layout' }
GolapProjectPresenter >> defaultLayout [

	^ SpBoxLayout newVertical
		  add: (SpBoxLayout newHorizontal
				   add: leftToolbar expand: true;
				   add: rightToolbar expand: false;
				   yourself)
		  expand: false;
		  add: (SpPanedLayout newHorizontal
				   positionOfSlider: 0.2;
				   add: (SpPanedLayout newVertical
						    positionOfSlider: 0.25;
						    add: (SpBoxLayout newVertical
								     add: projectList expand: true;
								     add: (SpBoxLayout newHorizontal
										      add: addProjectButton expand: true;
										      add: renameProjectButton expand: true;
										      add: removeProjectButton expand: true;
										      yourself)
								     expand: false;
								     add: saveProjectButton expand: false;
								     add: switchProjectButton expand: false;
								     yourself);
						    add: (SpBoxLayout newVertical
								     add: (SpBoxLayout newHorizontal
										      hAlignCenter;
										      add: 'ノート' expand: false)
								     expand: false;
								     add: notepad;
								     yourself);
						    yourself);
				   add: golapNotebook;
				   yourself);
		  yourself
]

{ #category : 'converting' }
GolapProjectPresenter >> fromJSON: aDictionary [

	aDictionary ifNotNil: [
			aDictionary isArray
				ifTrue: [ self restoreGolaps: aDictionary ]
				ifFalse: [
						| project |
						project := GolapProject fromJSON: aDictionary.
						aDictionary
							at: 'windows' ifPresent: [ :array | self restoreGolaps: array ];
							at: 'golaps' ifPresent: [ :array | self restoreGolaps: array ];
							at: 'golap-index' ifPresent: [ :integer | golapNotebook selectPageIndex: integer ] ] ]
]

{ #category : 'enumerating' }
GolapProjectPresenter >> golapsDo: aBlock [

	golapNotebook pages do: [ :page | (page activePresenter ifNil: [ page retrievePresenter ]) ifNotNil: aBlock ]
]

{ #category : 'accessing' }
GolapProjectPresenter >> iconFor: aGolapProject [

	^ aGolapProject = self currentProject
		  ifTrue: [ self iconNamed: #accept ]
		  ifFalse: [ nil ]
]

{ #category : 'initialization' }
GolapProjectPresenter >> initializePresenters [

	super initializePresenters.
	leftToolbar := self createLeftToolbar.
	rightToolbar := self createRightToolbar.
	projectList := self newTable
		               addColumn: ((SpImageTableColumn evaluated: [ :project | self iconFor: project ]) width: 32);
		               addColumn: (SpStringTableColumn title: 'プロジェクト名' evaluated: #projectName);
		               whenSelectedItemChangedDo: [ self selectedProjectChanged ];
		               whenBuiltDo: [ :ann | ann widget allowDeselection ];
		               yourself.
	notepad := self instantiate: GolapNotepad.
	addProjectButton := self newButton
		                    icon: (self iconNamed: #add);
		                    label: '作成';
		                    action: [ self addProject ];
		                    yourself.
	removeProjectButton := self newButton
		                       icon: (self iconNamed: #remove);
		                       label: '削除';
		                       action: [ self removeProject ];
		                       yourself.
	renameProjectButton := self newButton
		                       icon: (self iconNamed: #edit);
		                       label: '名前変更';
		                       action: [ self renameProject ];
		                       yourself.
	saveProjectButton := self newButton
		                     icon: (self iconNamed: #save);
		                     label: '保存';
		                     action: [ self saveProject ];
		                     yourself.
	switchProjectButton := self newButton
		                       icon: (self iconNamed: #accept);
		                       label: '開く';
		                       action: [ self switchProject ];
		                       yourself.
	golapNotebook := self newNotebook
		                 whenSelectedPageChangedDo: [ self selectedGolapPageChanged ];
		                 yourself.
	self
		updateProjectList;
		updateNotepad
]

{ #category : 'operations' }
GolapProjectPresenter >> removeProject [

	self selectedProject ifNotNil: [ :project |
			(self confirm: project projectName , 'を削除しますか？' title: 'プロジェクト削除') ifTrue: [
					project delete.
					self currentProject = project ifTrue: [ GolapProject default beCurrent ].
					self
						updateProjectList;
						updateNotepad ] ]
]

{ #category : 'operations' }
GolapProjectPresenter >> renameProject [

	self selectedProject ifNotNil: [ :project |
			project = self currentProject ifTrue: [ project beCurrent ].
			(self requestNewProject: project projectName) ifNotNil: [ :newProject |
					project renameTo: newProject projectName.
					self
						updateProjectList;
						updateNotepad ] ]
]

{ #category : 'ui requests' }
GolapProjectPresenter >> request: request initialAnswer: initialAnwser title: title [

	| answer |
	answer := self application newRequest
		          title: title;
		          message: request;
		          text: initialAnwser;
		          openModal.
	^ answer
]

{ #category : 'operations' }
GolapProjectPresenter >> requestNewProject: aString [

	| projectName project |
	[
		[
			projectName := self request: '新規プロジェクト名' initialAnswer: aString title: '新規プロジェクト作成'.
			projectName ifNil: [ ^ nil ].
			projectName := projectName trim.
			[ FileSystem disk checkName: projectName fixErrors: false ]
				on: Error
				do: [ :ex |
						self alert: 'ファイル名に使える名前を入力してください。' title: 'プロジェクト名エラー'.
						projectName := nil ].
			projectName isNil ] whileTrue.
		project := GolapProject named: projectName.
		project exists ifTrue: [
				self alert: 'そのプロジェクト名は既に使われています。' title: 'プロジェクト名エラー'.
				project := nil ].
		project isNil ] whileTrue.
	^ project
]

{ #category : 'private' }
GolapProjectPresenter >> restoreGolaps: anArray [

	| dialog |
	dialog := GolapProgressDialog new.
	dialog
		title: 'グラフ復元中...';
		informUserDuring: [ :progress |
				| pages |
				pages := Array new: anArray size.
				anArray withIndexDo: [ :json :index |
							| golap |
							progress progressPercent: index * 100 // anArray size.
							golap := Golap fromJSON: json.
							pages at: index put: (self newNotebookPage
										 presenterProvider: golap asValueHolder;
										 beCloseable;
										 title: golap windowTitle;
										 yourself) ].
				golapNotebook pages: pages ]
]

{ #category : 'operations' }
GolapProjectPresenter >> saveAsProject: aGolapProject [

	aGolapProject ifNotNil: [
			aGolapProject projectFile ifNotNil: [ :ref |
					self asJSON
						ifNotNil: [ :json |
								ref writeStreamDo: [ :stream |
										stream truncate.
										GolapProgressDialog new
											title: 'プロジェクトを保存中...';
											informUserDuring: [ :progress | GolapJSON put: json onStream: stream ] ] ]
						ifNil: [ self alert: self currentProjectName , 'の保存に失敗しました。' title: '保存失敗' ] ] ]
]

{ #category : 'operations' }
GolapProjectPresenter >> saveProject [

	| project |
	project := self currentProject ifDefault: [ self requestNewProject: '' ] otherwise: #yourself.
	self saveAsProject: project.
	project beCurrent.
	self
		updateProjectList;
		updateNotepad
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectProject: aGolapNamedProject [

	(projectList items includes: aGolapNamedProject)
		ifNotNil: [ :ref | projectList selectItem: aGolapNamedProject ]
		ifNil: [ projectList unselectAll ]
]

{ #category : 'updating' }
GolapProjectPresenter >> selectedGolapPageChanged [

	golapNotebook selectedPage ifNotNil: [ :page | page activePresenter selectedPageChanged ]
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProject [

	^ projectList selectedItem
]

{ #category : 'updating' }
GolapProjectPresenter >> selectedProjectChanged [

	self updateButtons
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectFile [

	^ self selectedProject ifNotNil: #projectFile
]

{ #category : 'accessing' }
GolapProjectPresenter >> selectedProjectName [

	^ self selectedProject ifNotNil: #projectName
]

{ #category : 'operations' }
GolapProjectPresenter >> switchProject [

	self selectedProject ifNotNil: [ :project |
			project = self currentProject
				ifTrue: [ (self confirm: self currentProjectName , 'を再読み込みしますか？' title: '再読み込みの確認') ifFalse: [ ^ self ] ]
				ifFalse: [ self confirmToSaveCurrentProject ifNil: [ ^ self ] ].
			project beCurrent.
			golapNotebook pages: Array new.
			project projectFile ifNotNil: [ :ref |
					ref readStreamDo: [ :stream |
							[ self fromJSON: (GolapJSON fromStream: stream) ]
								on: Error
								do: [ :ex | self alert: self currentProjectName , 'の読み込みに失敗しました。' title: '読み込み失敗' ] ] ].
			project beCurrent.
			self
				updateProjectList;
				updateNotepad ]
]

{ #category : 'converting' }
GolapProjectPresenter >> toJSON: aDictionary [

	self currentProject toJSON: aDictionary.
	aDictionary
		at: 'golaps' put: (Array streamContents: [ :stream | self golapsDo: [ :golap | stream nextPut: golap asJSON ] ]);
		at: 'golap-index' put: golapNotebook selectedPageIndex.
	^ aDictionary
]

{ #category : 'updating' }
GolapProjectPresenter >> updateButtons [

	| selected current |
	selected := self selectedProject.
	current := self currentProject.
	removeProjectButton enabled: selected notNil.
	renameProjectButton enabled: selected notNil.
	saveProjectButton enabled: (selected isNil or: [ selected = current ]).
	switchProjectButton enabled: selected notNil
]

{ #category : 'updating' }
GolapProjectPresenter >> updateGolapNotebookPageTitles [

	golapNotebook pages do: [ :page |
			page activePresenter ifNotNil: [ :golap |
					page
						title: golap windowTitle;
						pageTitleChanged ] ]
]

{ #category : 'updating' }
GolapProjectPresenter >> updateNotepad [

	notepad updatePages
]

{ #category : 'updating' }
GolapProjectPresenter >> updateProjectList [

	| selection |
	selection := projectList selectedItem.
	projectList items: GolapProject all.
	self selectProject: selection
]

{ #category : 'accessing' }
GolapProjectPresenter >> windowTitle [

	^ 'gOLAP'
]
