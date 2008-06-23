
var Columns = $A();

var ColumnBuilder = Class.create(HomeMarksApp,{
  
  initialize: function($super,id) { $super(); this.build(id); },
  
  build: function(id) {
    if (this.welcome.visible()) { this.welcome.hide(); };
    var colId = 'col_'+ id;
    var sortable = $('col_wrapper');
    var colHTML = DIV({id:colId,className:'dragable_columns'},[
      SPAN({className:'column_ctl'},[
        SPAN({className:'ctl_close'},''),
        SPAN({className:'ctl_handle'},''),
        SPAN({className:'ctl_add'},'')
      ])
    ]);
    sortable.insert({top:colHTML});
    var column = sortable.down('div.dragable_columns')
    var columnObject = new Column(column);
    Columns.push(columnObject);
    column.pulsate({duration:0.75});
    SortableUtils.createSortableMember(sortable,column);
  }
  
});

var Column = Class.create(HomeMarksApp,{
  
  initialize: function($super,column) {
    this.column = $(column);
    this.sortable = $('col_wrapper');
    this.id = parseInt(this.column.id.sub('col_',''));
    $super();
    this.controls = this.column.down('span.column_ctl');
    this._initColumnEvents();
  },
  
  boxes: function() {
    return Boxes.findAll(function(box){ return box.sortable == this.column }.bind(this));
  },
  
  completeDestroyColumn: function() {
    Columns = Columns.without(this);
    SortableUtils.destroySortableMember(this.sortable,this.column);
    this.flash('good','Column deleted.');
    this.column.fade({duration:0.25});
    setTimeout(function(){
      this.column.remove();
      if (!Columns.first()) { this.welcome.show(); };
      SortableUtils.resetSortableLastValue(this.sortable);
    }.bind(this),0350);
  },
  
  completeCreateBox: function(request) {
    var id = request.responseJSON;
    new BoxBuilder(this,id);
    this.flash('good','New box created.');
  },
  
  columnSortParams: function() {
    return SortableUtils.getSortParams(this.sortable);
  },
  
  completeColumnSort: function() {
    this.flash('good','Columns sorted.');
    SortableUtils.resetSortableLastValue(this.sortable);
  },
  
  
  _buildColumnSortables: function() {
    if (!Columns.sorted) {
      this.sortable.action = '/columns/sort';
      this.sortable.parameters = this.columnSortParams;
      this.sortable.method = 'put';
      Sortable.create(this.sortable, {
        handle:       'ctl_handle', 
        tag:          'div', 
        accept:       'dragable_columns', 
        containment:  this.sortable.id,
        constraint:   false, 
        dropOnEmpty:  true, 
        onUpdate: this.startAjaxRequest.bindAsEventListener(this,{onComplete:this.completeColumnSort}), 
      });
      Columns.sorted = true;
    };
  },
  
  _initDestroyCtl: function() {
    this.destroyCtl = this.controls.down('span.ctl_close');
    this.destroyCtl.confirmation = 'Are you sure? Deleting a COLUMN will also delete all the boxes and bookmarks within it.';
    this.destroyCtl.action = '/columns/' + this.id;
    this.destroyCtl.method = 'delete';
    this.createAjaxObserver(this.destroyCtl,{onComplete:this.completeDestroyColumn});
  },
  
  _initCreateBoxCtl: function() {
    this.createBoxCtl = this.controls.down('span.ctl_add');
    this.createBoxCtl.action = '/boxes';
    this.createBoxCtl.parameters = $H({column_id:this.id});
    this.createAjaxObserver(this.createBoxCtl,{onComplete:this.completeCreateBox});
  },
  
  _initColumnEvents: function() {
    this._buildColumnSortables();
    this._initDestroyCtl();
    this._initCreateBoxCtl();
  }
  
});


document.observe('dom:loaded', function(){
  $$('div.dragable_columns').each(function(column){ 
    var columnObject = new Column(column);
    Columns.push(columnObject);
  });
});

