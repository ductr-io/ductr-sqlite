# frozen_string_literal: true

RSpec.describe Rocket::SQLite::PaginatedSource do
  let(:source) { described_class.new("dummy_context", :dummy_method) }

  describe "control registration" do
    let(:registered) { Rocket::SQLite::Adapter.source_registry.find_by_type(:paginated) }

    it "registers as :paginated" do
      expect(registered).not_to be_nil
    end

    it "registers the the control class" do
      expect(registered).to eq(described_class)
    end
  end

  describe "#each_page" do
    let(:adapter_double) { instance_double(Rocket::SQLite::Adapter) }
    let(:db_double) { instance_double(Sequel::Database) }
    let(:query_double) { instance_double(Array) }

    before do
      source.instance_variable_set(:@offset, 0)
      allow(source).to receive(:page_size).and_return(1)
      allow(source).to receive(:adapter).and_return(adapter_double)
      allow(source).to receive(:call_method).and_return(query_double)
      allow(adapter_double).to receive(:db).and_return(db_double)
      allow(query_double).to receive(:each).and_yield(:row)
    end

    it "yields the row" do
      expect { |b| source.each_page(&b) }.to yield_with_args(:row)
    end

    it "returns true" do
      expect(source.each_page { |row| row }).to be(true)
    end

    context "with a dummy block" do
      before do
        source.each_page { |row| row }
      end

      it "calls method with database, offset and page size" do
        expect(source).to have_received(:call_method).with(db_double, 0, 1)
      end

      it "calls each on the query" do
        expect(query_double).to have_received(:each)
      end
    end

    context "with inconsistent pagination" do
      before do
        # return two rows for a page size of one
        allow(source).to receive(:call_method).and_return([0, 1])
      end

      it "raises an error" do
        expect { source.each_page { |row| row } }.to raise_error(Rocket::InconsistentPaginationError)
      end
    end
  end
end
