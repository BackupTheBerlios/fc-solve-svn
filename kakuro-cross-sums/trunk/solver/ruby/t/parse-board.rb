require "kakuro-board.rb"

describe "Parse 1" do
    before do
        @board = Kakuro::Board.new
        @board.parse(<<'EOF')
[\] [\] [29\] [\34\] [\] [21\] [8\] [\] [\]
[\] [10\17] [] [] [3\3] [] [] [\] [\]
[\30] [] [5] [] [] [2] [] [3\] [11\]
[\16] [] [] [6] [] [3] [12\11] [] []
[\] [4\5] [] [] [13\10] [] [] [] []
[\34] [] [7] [] [4] [] [] [11\] [\]
[\4] [] [] [3\12] [] [] [1] [] [\] 
[\] [\] [\6] [] [] [\11] [] [] [\]
[\] [\] [\3] [] [] [\] [\] [\] [\]
EOF
    end

    it "cell(0,0) is block" do
        @board.cell_yx(0,0).solid?.should
    end
end



