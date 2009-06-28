class LociController < ApplicationController
  # GET /loci
  # GET /loci.xml
  def index
    @loci = Locus.paginate(:page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @loci }
    end
  end

  # GET /loci/1
  # GET /loci/1.xml
  def show
    @locus = Locus.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @locus }
    end
  end

  # GET /loci/new
  # GET /loci/new.xml
  def new
    @locus = Locus.new
    @source = @locus.source
    @authorship = @source.authorship if @source

    respond_to do |format|
      format.html # new.html.erb
      format.xml { render :xml => @locus }
    end
  end

  # GET /loci/1/edit
  def edit
    @locus = Locus.find(params[:id])
    @source = @locus.source
    @authorship = @source.authorship
  end

  # POST /loci
  # POST /loci.xml
  def create
    @locus = Locus.new(params[:locus])
    @source = @locus.build_source(params[:source])
    @authorship = @source.build_authorship(params[:authorship])

    @authorship.title = params[:authorship][:title_id].empty? ? @authorship.build_title(params[:new_title]) : Title.find(params[:authorship][:title_id])
    @authorship.author = params[:authorship][:author_id].empty? ? @authorship.build_author(params[:new_author]) : Author.find(params[:authorship][:author_id])

    each_wikilink(params[:locus][:example]) do |linked, shown|
      att = @locus.attestations.build(:attested_form => shown)
      att.parses.build(:parsed_form => linked)
    end

    respond_to do |format|
      if [@source, @locus, @authorship].all?(&:save) #FIX
        flash[:notice] = 'Locus was successfully created.'
        format.html do
          case params[:commit]
          when "Create and continue editing" then render :action => 'edit'
          else redirect_to(@locus)
          end
        end
        format.xml { render :xml => @locus, :status => :created, :location => @locus }
      else
        format.html { render :action => "new" }
        format.xml { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /loci/1
  # PUT /loci/1.xml
  def update
    @locus = Locus.find(params[:id])
    @source = @locus.source
    @authorship = @source.authorship

    @authorship.title = params[:authorship][:title_id].empty? ? @authorship.build_title(params[:new_title]) : Title.find(params[:authorship][:title_id])
    @authorship.author = params[:authorship][:author_id].empty? ? @authorship.build_author(params[:new_author]) : Author.find(params[:authorship][:author_id])

    @locus.attributes = params[:locus]
    @source.attributes = params[:source]
    @authorship.attributes = params[:authorship]

    respond_to do |format|
      if [@source, @locus, @authorship].all?(&:save)
        flash[:notice] = 'Locus was successfully updated.'
        format.html do
          case params[:commit]
          when "Update and continue editing" then render :action => "edit"
          else redirect_to(@locus)
          end
        end
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @locus.errors, :status => :unprocessable_entity }
      end
    end
  end


  # DELETE /loci/1
  # DELETE /loci/1.xml
  def destroy
    @locus = Locus.find(params[:id])
    @locus.destroy

    respond_to do |format|
      format.html { redirect_to(loci_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def each_wikilink to_break
    broken = to_break.scan(/\[\[.+?\]\]\w*/)
    broken.each do |entry|
      entry.sub!(/\[\[/, '').sub!(/\]\]/, '')

      shown = entry.include?("|") ? entry.gsub(/.+\|/, '') : entry
      linked = entry.include?("|") ? entry.gsub(/\|.+/, '') : entry

      yield(linked, shown)
    end
  end
end
