require "hitori-solver.rb"

class Object
    def ok()
        self.should == true
    end
    def not_ok()
        self.should == false
    end
end

describe "construct_board" do
    it "board No. 1 should" do
        # http://www.menneske.no/hitori/5x5/eng/showpuzzle.html?number=1
        contents = [
            [2,1,3,2,4],
            [4,5,3,2,2],
            [3,4,2,5,1],
            [1,4,3,3,2],
            [2,5,1,4,3]
        ]
        board = HitoriSolver::Board.new(5, 5, contents)
        board.cell_yx(0,0).value.should == 2
        board.cell_yx(0,1).value.should == 1
        board.cell_yx(0,2).value.should == 3
    end
end
