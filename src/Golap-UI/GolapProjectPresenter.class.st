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
		'rightToolbar',
		'showsProjectAndNote',
		'toggleShowProjectAndNoteButton'
	],
	#classVars : [
		'Current',
		'Logo'
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

{ #category : 'accessing' }
GolapProjectPresenter class >> logoImage [

	^ Logo ifNil: [ Logo := BaselineOfGolap logoImageWithCodename ]
]

{ #category : 'operations' }
GolapProjectPresenter class >> open [

	<script: 'GolapProjectPresenter open'>
	| window |
	self flushCurrent.
	self current updateProjectList.
	window := self current window ifNil: [ self current asWindow ].
	window isOpen
		ifTrue: [ window activate ]
		ifFalse: [ window open maximize ]
]

{ #category : 'menus' }
GolapProjectPresenter class >> openFullScreen [

	self current asWorldWindow
		title: 'gOLAP';
		open
]

{ #category : 'operations' }
GolapProjectPresenter >> addClip: aGolapClip [

	notepad addClip: aGolapClip
]

{ #category : 'operations' }
GolapProjectPresenter >> addPresenter: aGolap [

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
					self clearGolapPages.
					project beCurrent.
					self saveAsProject: project.
					self selectProject: project.
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

{ #category : 'operations' }
GolapProjectPresenter >> clearGolapPages [

	golapNotebook pages: Array new
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

	self currentProject
		ifDefault: [
				| ans |
				ans := self confirmYesNoCancel: '現在のプロジェクトを保存しますか？' title: '保存の確認'.
				ans = true ifTrue: [ (self requestNewProject: '') ifNotNil: [ :project | self saveAsProject: project ] ].
				^ ans ]
		otherwise: [ :current |
				| ans |
				ans := self confirmYesNoCancel: current projectName , 'を保存しますか？' title: '保存の確認'.
				ans = true ifTrue: [ self saveAsProject: current ].
				^ ans ]
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
		  add: (showsProjectAndNote
				   ifTrue: [
						   SpBoxLayout newHorizontal
							   add: (SpBoxLayout newHorizontal add: (SpBoxLayout newVertical
											     add: projectList height: 400;
											     add: (SpBoxLayout newHorizontal
													      add: addProjectButton expand: true;
													      add: renameProjectButton expand: true;
													      add: removeProjectButton expand: true;
													      yourself)
											     expand: false;
											     add: saveProjectButton expand: false;
											     add: switchProjectButton expand: false;
											     add: (SpBoxLayout newHorizontal
													      hAlignCenter;
													      add: 'ノート' asPresenter expand: false;
													      yourself)
											     expand: false;
											     add: notepad expand: true;
											     yourself))
							   width: 400;
							   add: toggleShowProjectAndNoteButton width: 20;
							   add: golapNotebook;
							   yourself ]
				   ifFalse: [
						   SpBoxLayout newHorizontal
							   add: toggleShowProjectAndNoteButton width: 20;
							   add: golapNotebook;
							   yourself ])
		  expand: true;
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
						project beCurrent.
						aDictionary
							at: 'windows' ifPresent: [ :array | self restoreGolaps: array ];
							at: 'golaps' ifPresent: [ :array | self restoreGolaps: array ];
							at: 'golap-index' ifPresent: [ :integer | integer > 0 ifTrue: [ golapNotebook selectPageIndex: integer ] ] ] ]
]

{ #category : 'operations' }
GolapProjectPresenter >> hideProjectAndNote [

	showsProjectAndNote := false.
	self updateToggleShowProjectAndNoteButton
]

{ #category : 'accessing' }
GolapProjectPresenter >> iconFor: aGolapProject [

	^ aGolapProject = self currentProject
		  ifTrue: [ self iconNamed: #accept ]
		  ifFalse: [ nil ]
]

{ #category : 'initialization' }
GolapProjectPresenter >> initialize [

	super initialize.
	self showProjectAndNote
]

{ #category : 'initialization' }
GolapProjectPresenter >> initializePresenters [

	super initializePresenters.
	leftToolbar := self createLeftToolbar.
	rightToolbar := self createRightToolbar.
	toggleShowProjectAndNoteButton := self newButton
		                                  label: '≪';
		                                  action: [ self toggleShowProjectAndNote ];
		                                  yourself.
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
		                 addPageTitle: 'About gOLAP client' provider: [
				                 | image |
				                 image := self logoImage asPresenter.
				                 image
					                 autoScale: false;
					                 whenBuiltDo: [ image adapter widget color: Color white ].
				                 image ];
		                 whenSelectedPageChangedDo: [ self selectedGolapPageChanged ];
		                 yourself.
	self
		updateProjectList;
		updateNotepad
]

{ #category : 'accessing' }
GolapProjectPresenter >> logoImage [

	^ self class logoImage
]

{ #category : 'enumerating' }
GolapProjectPresenter >> presentersDo: aBlock [

	golapNotebook pages do: [ :page | (page activePresenter ifNil: [ page retrievePresenter ]) ifNotNil: aBlock ]
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

	| pages |
	pages := Array new: anArray size.
	anArray withIndexDo: [ :json :index |
			| golap |
			golap := Golap fromJSON: json.
			pages at: index put: (self newNotebookPage
					 presenterProvider: golap asValueHolder;
					 beCloseable;
					 title: golap windowTitle;
					 yourself) ].
	golapNotebook pages: pages
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
											informUserDuring: [ :progress |
													GolapJSON put: json onStream: stream.
													1 second wait ] ] ]
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

	golapNotebook selectedPage ifNotNil: [ :page |
		page activePresenter ifNotNil: [ :presenter | (presenter isKindOf: Golap) ifTrue: [ presenter selectedPageChanged ] ] ]
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
GolapProjectPresenter >> showProjectAndNote [

	showsProjectAndNote := true.
	self updateToggleShowProjectAndNoteButton
]

{ #category : 'testing' }
GolapProjectPresenter >> showsProjectAndNote [

	^ showsProjectAndNote
]

{ #category : 'operations' }
GolapProjectPresenter >> switchProject [

	self selectedProject ifNotNil: [ :project |
			project = self currentProject
				ifTrue: [ (self confirm: self currentProjectName , 'を再読み込みしますか？' title: '再読み込みの確認') ifFalse: [ ^ self ] ]
				ifFalse: [ self confirmToSaveCurrentProject ifNil: [ ^ self ] ].
			self clearGolapPages.
			project projectFile ifNotNil: [ :ref |
					ref readStreamDo: [ :stream |
							[
								GolapProgressDialog new
									title: 'プロジェクト読み込み中…';
									informUserDuring: [ :progress |
											self fromJSON: (GolapJSON fromStream: stream).
											self currentProject projectFile: ref ] ]
								on: Error
								do: [ :ex | self alert: self currentProjectName , 'の読み込みに失敗しました。' title: '読み込み失敗' ] ] ].
			self
				updateProjectList;
				updateNotepad ]
]

{ #category : 'converting' }
GolapProjectPresenter >> toJSON: aDictionary [

	self currentProject toJSON: aDictionary.
	aDictionary
		at: 'windows' put: (Array streamContents: [ :stream | self presentersDo: [ :presenter | stream nextPut: presenter asJSON ] ]);
		at: 'golap-index' put: golapNotebook selectedPageIndex.
	^ aDictionary
]

{ #category : 'operations' }
GolapProjectPresenter >> toggleShowProjectAndNote [

	showsProjectAndNote := showsProjectAndNote not.
	self updateToggleShowProjectAndNoteButton.
	self layout: self defaultLayout
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
			page activePresenter ifNotNil: [ :presenter |
					(presenter class usesTrait: TGolapSnapshotablePresenter) ifTrue: [
							page
								title: presenter windowTitle;
								pageTitleChanged ] ] ]
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

{ #category : 'updating' }
GolapProjectPresenter >> updateToggleShowProjectAndNoteButton [

	toggleShowProjectAndNoteButton label: (showsProjectAndNote
			 ifTrue: [ '≪' ]
			 ifFalse: [ '≫' ])
]

{ #category : 'accessing' }
GolapProjectPresenter >> windowTitle [

	^ 'gOLAP'
]
