module {
  llvm.func @memrefCopy(i64, !llvm.ptr, !llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @matmul_bias_relu(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> {
    %0 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg2, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg5, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg4, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg6, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg7, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg8, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg9, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg10, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg12, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg11, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg13, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = llvm.insertvalue %arg14, %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.insertvalue %arg15, %17[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %19 = llvm.insertvalue %arg16, %18[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.insertvalue %arg17, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %21 = llvm.insertvalue %arg18, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %22 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %23 = llvm.mlir.constant(1 : index) : i64
    %24 = llvm.mlir.constant(256 : index) : i64
    %25 = llvm.mlir.constant(64 : index) : i64
    %26 = llvm.mlir.constant(128 : index) : i64
    %27 = llvm.mlir.constant(0 : index) : i64
    %28 = llvm.mlir.constant(128 : index) : i64
    %29 = llvm.mlir.constant(256 : index) : i64
    %30 = llvm.mlir.constant(1 : index) : i64
    %31 = llvm.mlir.constant(32768 : index) : i64
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.getelementptr %32[32768] : (!llvm.ptr) -> !llvm.ptr, f32
    %34 = llvm.ptrtoint %33 : !llvm.ptr to i64
    %35 = llvm.mlir.constant(64 : index) : i64
    %36 = llvm.add %34, %35  : i64
    %37 = llvm.call @malloc(%36) : (i64) -> !llvm.ptr
    %38 = llvm.ptrtoint %37 : !llvm.ptr to i64
    %39 = llvm.mlir.constant(1 : index) : i64
    %40 = llvm.sub %35, %39  : i64
    %41 = llvm.add %38, %40  : i64
    %42 = llvm.urem %41, %35  : i64
    %43 = llvm.sub %41, %42  : i64
    %44 = llvm.inttoptr %43 : i64 to !llvm.ptr
    %45 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %46 = llvm.insertvalue %37, %45[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %44, %46[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.mlir.constant(0 : index) : i64
    %49 = llvm.insertvalue %48, %47[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.insertvalue %28, %49[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.insertvalue %29, %50[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.insertvalue %29, %51[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.insertvalue %30, %52[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.mlir.constant(128 : index) : i64
    %55 = llvm.mlir.constant(256 : index) : i64
    %56 = llvm.mlir.constant(1 : index) : i64
    %57 = llvm.mlir.constant(32768 : index) : i64
    %58 = llvm.mlir.zero : !llvm.ptr
    %59 = llvm.getelementptr %58[32768] : (!llvm.ptr) -> !llvm.ptr, f32
    %60 = llvm.ptrtoint %59 : !llvm.ptr to i64
    %61 = llvm.mlir.constant(64 : index) : i64
    %62 = llvm.add %60, %61  : i64
    %63 = llvm.call @malloc(%62) : (i64) -> !llvm.ptr
    %64 = llvm.ptrtoint %63 : !llvm.ptr to i64
    %65 = llvm.mlir.constant(1 : index) : i64
    %66 = llvm.sub %61, %65  : i64
    %67 = llvm.add %64, %66  : i64
    %68 = llvm.urem %67, %61  : i64
    %69 = llvm.sub %67, %68  : i64
    %70 = llvm.inttoptr %69 : i64 to !llvm.ptr
    %71 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %72 = llvm.insertvalue %63, %71[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %73 = llvm.insertvalue %70, %72[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %74 = llvm.mlir.constant(0 : index) : i64
    %75 = llvm.insertvalue %74, %73[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %76 = llvm.insertvalue %54, %75[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %77 = llvm.insertvalue %55, %76[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %78 = llvm.insertvalue %55, %77[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %79 = llvm.insertvalue %56, %78[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%27 : i64)
  ^bb1(%80: i64):  // 2 preds: ^bb0, ^bb5
    %81 = llvm.icmp "slt" %80, %26 : i64
    llvm.cond_br %81, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%27 : i64)
  ^bb3(%82: i64):  // 2 preds: ^bb2, ^bb4
    %83 = llvm.icmp "slt" %82, %24 : i64
    llvm.cond_br %83, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %84 = llvm.mlir.constant(256 : index) : i64
    %85 = llvm.mul %80, %84  : i64
    %86 = llvm.add %85, %82  : i64
    %87 = llvm.getelementptr %70[%86] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %22, %87 : f32, !llvm.ptr
    %88 = llvm.add %82, %23  : i64
    llvm.br ^bb3(%88 : i64)
  ^bb5:  // pred: ^bb3
    %89 = llvm.add %80, %23  : i64
    llvm.br ^bb1(%89 : i64)
  ^bb6:  // pred: ^bb1
    llvm.br ^bb7(%27 : i64)
  ^bb7(%90: i64):  // 2 preds: ^bb6, ^bb20
    %91 = llvm.icmp "slt" %90, %26 : i64
    llvm.cond_br %91, ^bb8, ^bb21
  ^bb8:  // pred: ^bb7
    llvm.br ^bb9(%27 : i64)
  ^bb9(%92: i64):  // 2 preds: ^bb8, ^bb19
    %93 = llvm.icmp "slt" %92, %24 : i64
    llvm.cond_br %93, ^bb10, ^bb20
  ^bb10:  // pred: ^bb9
    %94 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %95 = llvm.insertvalue %arg0, %94[0] : !llvm.struct<(ptr, ptr, i64)> 
    %96 = llvm.insertvalue %arg1, %95[1] : !llvm.struct<(ptr, ptr, i64)> 
    %97 = llvm.mlir.constant(0 : index) : i64
    %98 = llvm.insertvalue %97, %96[2] : !llvm.struct<(ptr, ptr, i64)> 
    %99 = llvm.mlir.constant(64 : index) : i64
    %100 = llvm.mul %90, %99  : i64
    %101 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %102 = llvm.insertvalue %arg0, %101[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %103 = llvm.insertvalue %arg1, %102[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %104 = llvm.insertvalue %100, %103[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.mlir.constant(64 : index) : i64
    %106 = llvm.insertvalue %105, %104[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %107 = llvm.mlir.constant(64 : index) : i64
    %108 = llvm.insertvalue %107, %106[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %109 = llvm.mlir.constant(64 : index) : i64
    %110 = llvm.insertvalue %109, %108[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %111 = llvm.mlir.constant(1 : index) : i64
    %112 = llvm.insertvalue %111, %110[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %113 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %114 = llvm.insertvalue %arg7, %113[0] : !llvm.struct<(ptr, ptr, i64)> 
    %115 = llvm.insertvalue %arg8, %114[1] : !llvm.struct<(ptr, ptr, i64)> 
    %116 = llvm.mlir.constant(0 : index) : i64
    %117 = llvm.insertvalue %116, %115[2] : !llvm.struct<(ptr, ptr, i64)> 
    %118 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %119 = llvm.insertvalue %arg7, %118[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %120 = llvm.insertvalue %arg8, %119[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %121 = llvm.insertvalue %92, %120[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.mlir.constant(64 : index) : i64
    %123 = llvm.insertvalue %122, %121[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.mlir.constant(256 : index) : i64
    %125 = llvm.insertvalue %124, %123[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.mlir.constant(64 : index) : i64
    %127 = llvm.insertvalue %126, %125[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %128 = llvm.mlir.constant(1 : index) : i64
    %129 = llvm.insertvalue %128, %127[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %130 = llvm.mlir.constant(256 : index) : i64
    %131 = llvm.mul %90, %130  : i64
    %132 = llvm.add %131, %92  : i64
    %133 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %134 = llvm.insertvalue %63, %133[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %135 = llvm.insertvalue %70, %134[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %136 = llvm.insertvalue %132, %135[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %137 = llvm.mlir.constant(64 : index) : i64
    %138 = llvm.insertvalue %137, %136[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %139 = llvm.mlir.constant(256 : index) : i64
    %140 = llvm.insertvalue %139, %138[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %141 = llvm.mlir.constant(64 : index) : i64
    %142 = llvm.insertvalue %141, %140[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %143 = llvm.mlir.constant(1 : index) : i64
    %144 = llvm.insertvalue %143, %142[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb11(%27 : i64)
  ^bb11(%145: i64):  // 2 preds: ^bb10, ^bb18
    %146 = llvm.icmp "slt" %145, %25 : i64
    llvm.cond_br %146, ^bb12, ^bb19
  ^bb12:  // pred: ^bb11
    llvm.br ^bb13(%27 : i64)
  ^bb13(%147: i64):  // 2 preds: ^bb12, ^bb17
    %148 = llvm.icmp "slt" %147, %25 : i64
    llvm.cond_br %148, ^bb14, ^bb18
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%27 : i64)
  ^bb15(%149: i64):  // 2 preds: ^bb14, ^bb16
    %150 = llvm.icmp "slt" %149, %25 : i64
    llvm.cond_br %150, ^bb16, ^bb17
  ^bb16:  // pred: ^bb15
    %151 = llvm.getelementptr %arg1[%100] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %152 = llvm.mlir.constant(64 : index) : i64
    %153 = llvm.mul %145, %152  : i64
    %154 = llvm.add %153, %149  : i64
    %155 = llvm.getelementptr %151[%154] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %156 = llvm.load %155 : !llvm.ptr -> f32
    %157 = llvm.getelementptr %arg8[%92] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %158 = llvm.mlir.constant(256 : index) : i64
    %159 = llvm.mul %149, %158  : i64
    %160 = llvm.add %159, %147  : i64
    %161 = llvm.getelementptr %157[%160] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %162 = llvm.load %161 : !llvm.ptr -> f32
    %163 = llvm.getelementptr %70[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %164 = llvm.mlir.constant(256 : index) : i64
    %165 = llvm.mul %145, %164  : i64
    %166 = llvm.add %165, %147  : i64
    %167 = llvm.getelementptr %163[%166] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %168 = llvm.load %167 : !llvm.ptr -> f32
    %169 = llvm.fmul %156, %162  : f32
    %170 = llvm.fadd %168, %169  : f32
    %171 = llvm.getelementptr %70[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %172 = llvm.mlir.constant(256 : index) : i64
    %173 = llvm.mul %145, %172  : i64
    %174 = llvm.add %173, %147  : i64
    %175 = llvm.getelementptr %171[%174] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %170, %175 : f32, !llvm.ptr
    %176 = llvm.add %149, %23  : i64
    llvm.br ^bb15(%176 : i64)
  ^bb17:  // pred: ^bb15
    %177 = llvm.add %147, %23  : i64
    llvm.br ^bb13(%177 : i64)
  ^bb18:  // pred: ^bb13
    %178 = llvm.add %145, %23  : i64
    llvm.br ^bb11(%178 : i64)
  ^bb19:  // pred: ^bb11
    %179 = llvm.intr.stacksave : !llvm.ptr
    %180 = llvm.mlir.constant(2 : i64) : i64
    %181 = llvm.mlir.constant(1 : index) : i64
    %182 = llvm.alloca %181 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %144, %182 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %183 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %184 = llvm.insertvalue %180, %183[0] : !llvm.struct<(i64, ptr)> 
    %185 = llvm.insertvalue %182, %184[1] : !llvm.struct<(i64, ptr)> 
    %186 = llvm.mlir.constant(2 : i64) : i64
    %187 = llvm.mlir.constant(1 : index) : i64
    %188 = llvm.alloca %187 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %144, %188 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %189 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %190 = llvm.insertvalue %186, %189[0] : !llvm.struct<(i64, ptr)> 
    %191 = llvm.insertvalue %188, %190[1] : !llvm.struct<(i64, ptr)> 
    %192 = llvm.mlir.constant(1 : index) : i64
    %193 = llvm.alloca %192 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %185, %193 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %194 = llvm.alloca %192 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %191, %194 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %195 = llvm.mlir.zero : !llvm.ptr
    %196 = llvm.getelementptr %195[1] : (!llvm.ptr) -> !llvm.ptr, f32
    %197 = llvm.ptrtoint %196 : !llvm.ptr to i64
    llvm.call @memrefCopy(%197, %193, %194) : (i64, !llvm.ptr, !llvm.ptr) -> ()
    llvm.intr.stackrestore %179 : !llvm.ptr
    %198 = llvm.add %92, %25  : i64
    llvm.br ^bb9(%198 : i64)
  ^bb20:  // pred: ^bb9
    %199 = llvm.add %90, %25  : i64
    llvm.br ^bb7(%199 : i64)
  ^bb21:  // pred: ^bb7
    llvm.br ^bb22(%27 : i64)
  ^bb22(%200: i64):  // 2 preds: ^bb21, ^bb26
    %201 = llvm.icmp "slt" %200, %26 : i64
    llvm.cond_br %201, ^bb23, ^bb27
  ^bb23:  // pred: ^bb22
    llvm.br ^bb24(%27 : i64)
  ^bb24(%202: i64):  // 2 preds: ^bb23, ^bb25
    %203 = llvm.icmp "slt" %202, %24 : i64
    llvm.cond_br %203, ^bb25, ^bb26
  ^bb25:  // pred: ^bb24
    %204 = llvm.mlir.constant(256 : index) : i64
    %205 = llvm.mul %200, %204  : i64
    %206 = llvm.add %205, %202  : i64
    %207 = llvm.getelementptr %70[%206] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %208 = llvm.load %207 : !llvm.ptr -> f32
    %209 = llvm.getelementptr %arg15[%202] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %210 = llvm.load %209 : !llvm.ptr -> f32
    %211 = llvm.fadd %208, %210  : f32
    %212 = llvm.intr.maximum(%211, %22)  : (f32, f32) -> f32
    %213 = llvm.mlir.constant(256 : index) : i64
    %214 = llvm.mul %200, %213  : i64
    %215 = llvm.add %214, %202  : i64
    %216 = llvm.getelementptr %44[%215] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %212, %216 : f32, !llvm.ptr
    %217 = llvm.add %202, %23  : i64
    llvm.br ^bb24(%217 : i64)
  ^bb26:  // pred: ^bb24
    %218 = llvm.add %200, %23  : i64
    llvm.br ^bb22(%218 : i64)
  ^bb27:  // pred: ^bb22
    llvm.return %53 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @no_fusion_multi_use(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64) -> !llvm.struct<(struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>)> {
    %0 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %1 = llvm.insertvalue %arg0, %0[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %2 = llvm.insertvalue %arg1, %1[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %3 = llvm.insertvalue %arg2, %2[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %4 = llvm.insertvalue %arg3, %3[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %5 = llvm.insertvalue %arg5, %4[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %6 = llvm.insertvalue %arg4, %5[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %7 = llvm.insertvalue %arg6, %6[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %8 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %9 = llvm.insertvalue %arg7, %8[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %10 = llvm.insertvalue %arg8, %9[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %11 = llvm.insertvalue %arg9, %10[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %12 = llvm.insertvalue %arg10, %11[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %13 = llvm.insertvalue %arg12, %12[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %14 = llvm.insertvalue %arg11, %13[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %15 = llvm.insertvalue %arg13, %14[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %16 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %17 = llvm.insertvalue %arg14, %16[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %18 = llvm.insertvalue %arg15, %17[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %19 = llvm.insertvalue %arg16, %18[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %20 = llvm.insertvalue %arg17, %19[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %21 = llvm.insertvalue %arg18, %20[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %22 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %23 = llvm.mlir.constant(1 : index) : i64
    %24 = llvm.mlir.constant(256 : index) : i64
    %25 = llvm.mlir.constant(64 : index) : i64
    %26 = llvm.mlir.constant(128 : index) : i64
    %27 = llvm.mlir.constant(0 : index) : i64
    %28 = llvm.mlir.constant(128 : index) : i64
    %29 = llvm.mlir.constant(256 : index) : i64
    %30 = llvm.mlir.constant(1 : index) : i64
    %31 = llvm.mlir.constant(32768 : index) : i64
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.getelementptr %32[32768] : (!llvm.ptr) -> !llvm.ptr, f32
    %34 = llvm.ptrtoint %33 : !llvm.ptr to i64
    %35 = llvm.mlir.constant(64 : index) : i64
    %36 = llvm.add %34, %35  : i64
    %37 = llvm.call @malloc(%36) : (i64) -> !llvm.ptr
    %38 = llvm.ptrtoint %37 : !llvm.ptr to i64
    %39 = llvm.mlir.constant(1 : index) : i64
    %40 = llvm.sub %35, %39  : i64
    %41 = llvm.add %38, %40  : i64
    %42 = llvm.urem %41, %35  : i64
    %43 = llvm.sub %41, %42  : i64
    %44 = llvm.inttoptr %43 : i64 to !llvm.ptr
    %45 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %46 = llvm.insertvalue %37, %45[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %47 = llvm.insertvalue %44, %46[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %48 = llvm.mlir.constant(0 : index) : i64
    %49 = llvm.insertvalue %48, %47[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %50 = llvm.insertvalue %28, %49[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %51 = llvm.insertvalue %29, %50[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %52 = llvm.insertvalue %29, %51[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %53 = llvm.insertvalue %30, %52[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %54 = llvm.mlir.constant(128 : index) : i64
    %55 = llvm.mlir.constant(256 : index) : i64
    %56 = llvm.mlir.constant(1 : index) : i64
    %57 = llvm.mlir.constant(32768 : index) : i64
    %58 = llvm.mlir.zero : !llvm.ptr
    %59 = llvm.getelementptr %58[32768] : (!llvm.ptr) -> !llvm.ptr, f32
    %60 = llvm.ptrtoint %59 : !llvm.ptr to i64
    %61 = llvm.mlir.constant(64 : index) : i64
    %62 = llvm.add %60, %61  : i64
    %63 = llvm.call @malloc(%62) : (i64) -> !llvm.ptr
    %64 = llvm.ptrtoint %63 : !llvm.ptr to i64
    %65 = llvm.mlir.constant(1 : index) : i64
    %66 = llvm.sub %61, %65  : i64
    %67 = llvm.add %64, %66  : i64
    %68 = llvm.urem %67, %61  : i64
    %69 = llvm.sub %67, %68  : i64
    %70 = llvm.inttoptr %69 : i64 to !llvm.ptr
    %71 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %72 = llvm.insertvalue %63, %71[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %73 = llvm.insertvalue %70, %72[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %74 = llvm.mlir.constant(0 : index) : i64
    %75 = llvm.insertvalue %74, %73[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %76 = llvm.insertvalue %54, %75[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %77 = llvm.insertvalue %55, %76[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %78 = llvm.insertvalue %55, %77[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %79 = llvm.insertvalue %56, %78[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%27 : i64)
  ^bb1(%80: i64):  // 2 preds: ^bb0, ^bb5
    %81 = llvm.icmp "slt" %80, %26 : i64
    llvm.cond_br %81, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%27 : i64)
  ^bb3(%82: i64):  // 2 preds: ^bb2, ^bb4
    %83 = llvm.icmp "slt" %82, %24 : i64
    llvm.cond_br %83, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %84 = llvm.mlir.constant(256 : index) : i64
    %85 = llvm.mul %80, %84  : i64
    %86 = llvm.add %85, %82  : i64
    %87 = llvm.getelementptr %70[%86] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %22, %87 : f32, !llvm.ptr
    %88 = llvm.add %82, %23  : i64
    llvm.br ^bb3(%88 : i64)
  ^bb5:  // pred: ^bb3
    %89 = llvm.add %80, %23  : i64
    llvm.br ^bb1(%89 : i64)
  ^bb6:  // pred: ^bb1
    llvm.br ^bb7(%27 : i64)
  ^bb7(%90: i64):  // 2 preds: ^bb6, ^bb20
    %91 = llvm.icmp "slt" %90, %26 : i64
    llvm.cond_br %91, ^bb8, ^bb21
  ^bb8:  // pred: ^bb7
    llvm.br ^bb9(%27 : i64)
  ^bb9(%92: i64):  // 2 preds: ^bb8, ^bb19
    %93 = llvm.icmp "slt" %92, %24 : i64
    llvm.cond_br %93, ^bb10, ^bb20
  ^bb10:  // pred: ^bb9
    %94 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %95 = llvm.insertvalue %arg0, %94[0] : !llvm.struct<(ptr, ptr, i64)> 
    %96 = llvm.insertvalue %arg1, %95[1] : !llvm.struct<(ptr, ptr, i64)> 
    %97 = llvm.mlir.constant(0 : index) : i64
    %98 = llvm.insertvalue %97, %96[2] : !llvm.struct<(ptr, ptr, i64)> 
    %99 = llvm.mlir.constant(64 : index) : i64
    %100 = llvm.mul %90, %99  : i64
    %101 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %102 = llvm.insertvalue %arg0, %101[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %103 = llvm.insertvalue %arg1, %102[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %104 = llvm.insertvalue %100, %103[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.mlir.constant(64 : index) : i64
    %106 = llvm.insertvalue %105, %104[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %107 = llvm.mlir.constant(64 : index) : i64
    %108 = llvm.insertvalue %107, %106[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %109 = llvm.mlir.constant(64 : index) : i64
    %110 = llvm.insertvalue %109, %108[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %111 = llvm.mlir.constant(1 : index) : i64
    %112 = llvm.insertvalue %111, %110[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %113 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %114 = llvm.insertvalue %arg7, %113[0] : !llvm.struct<(ptr, ptr, i64)> 
    %115 = llvm.insertvalue %arg8, %114[1] : !llvm.struct<(ptr, ptr, i64)> 
    %116 = llvm.mlir.constant(0 : index) : i64
    %117 = llvm.insertvalue %116, %115[2] : !llvm.struct<(ptr, ptr, i64)> 
    %118 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %119 = llvm.insertvalue %arg7, %118[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %120 = llvm.insertvalue %arg8, %119[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %121 = llvm.insertvalue %92, %120[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.mlir.constant(64 : index) : i64
    %123 = llvm.insertvalue %122, %121[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.mlir.constant(256 : index) : i64
    %125 = llvm.insertvalue %124, %123[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.mlir.constant(64 : index) : i64
    %127 = llvm.insertvalue %126, %125[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %128 = llvm.mlir.constant(1 : index) : i64
    %129 = llvm.insertvalue %128, %127[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %130 = llvm.mlir.constant(256 : index) : i64
    %131 = llvm.mul %90, %130  : i64
    %132 = llvm.add %131, %92  : i64
    %133 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %134 = llvm.insertvalue %63, %133[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %135 = llvm.insertvalue %70, %134[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %136 = llvm.insertvalue %132, %135[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %137 = llvm.mlir.constant(64 : index) : i64
    %138 = llvm.insertvalue %137, %136[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %139 = llvm.mlir.constant(256 : index) : i64
    %140 = llvm.insertvalue %139, %138[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %141 = llvm.mlir.constant(64 : index) : i64
    %142 = llvm.insertvalue %141, %140[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %143 = llvm.mlir.constant(1 : index) : i64
    %144 = llvm.insertvalue %143, %142[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb11(%27 : i64)
  ^bb11(%145: i64):  // 2 preds: ^bb10, ^bb18
    %146 = llvm.icmp "slt" %145, %25 : i64
    llvm.cond_br %146, ^bb12, ^bb19
  ^bb12:  // pred: ^bb11
    llvm.br ^bb13(%27 : i64)
  ^bb13(%147: i64):  // 2 preds: ^bb12, ^bb17
    %148 = llvm.icmp "slt" %147, %25 : i64
    llvm.cond_br %148, ^bb14, ^bb18
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%27 : i64)
  ^bb15(%149: i64):  // 2 preds: ^bb14, ^bb16
    %150 = llvm.icmp "slt" %149, %25 : i64
    llvm.cond_br %150, ^bb16, ^bb17
  ^bb16:  // pred: ^bb15
    %151 = llvm.getelementptr %arg1[%100] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %152 = llvm.mlir.constant(64 : index) : i64
    %153 = llvm.mul %145, %152  : i64
    %154 = llvm.add %153, %149  : i64
    %155 = llvm.getelementptr %151[%154] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %156 = llvm.load %155 : !llvm.ptr -> f32
    %157 = llvm.getelementptr %arg8[%92] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %158 = llvm.mlir.constant(256 : index) : i64
    %159 = llvm.mul %149, %158  : i64
    %160 = llvm.add %159, %147  : i64
    %161 = llvm.getelementptr %157[%160] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %162 = llvm.load %161 : !llvm.ptr -> f32
    %163 = llvm.getelementptr %70[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %164 = llvm.mlir.constant(256 : index) : i64
    %165 = llvm.mul %145, %164  : i64
    %166 = llvm.add %165, %147  : i64
    %167 = llvm.getelementptr %163[%166] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %168 = llvm.load %167 : !llvm.ptr -> f32
    %169 = llvm.fmul %156, %162  : f32
    %170 = llvm.fadd %168, %169  : f32
    %171 = llvm.getelementptr %70[%132] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %172 = llvm.mlir.constant(256 : index) : i64
    %173 = llvm.mul %145, %172  : i64
    %174 = llvm.add %173, %147  : i64
    %175 = llvm.getelementptr %171[%174] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %170, %175 : f32, !llvm.ptr
    %176 = llvm.add %149, %23  : i64
    llvm.br ^bb15(%176 : i64)
  ^bb17:  // pred: ^bb15
    %177 = llvm.add %147, %23  : i64
    llvm.br ^bb13(%177 : i64)
  ^bb18:  // pred: ^bb13
    %178 = llvm.add %145, %23  : i64
    llvm.br ^bb11(%178 : i64)
  ^bb19:  // pred: ^bb11
    %179 = llvm.intr.stacksave : !llvm.ptr
    %180 = llvm.mlir.constant(2 : i64) : i64
    %181 = llvm.mlir.constant(1 : index) : i64
    %182 = llvm.alloca %181 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %144, %182 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %183 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %184 = llvm.insertvalue %180, %183[0] : !llvm.struct<(i64, ptr)> 
    %185 = llvm.insertvalue %182, %184[1] : !llvm.struct<(i64, ptr)> 
    %186 = llvm.mlir.constant(2 : i64) : i64
    %187 = llvm.mlir.constant(1 : index) : i64
    %188 = llvm.alloca %187 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %144, %188 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %189 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %190 = llvm.insertvalue %186, %189[0] : !llvm.struct<(i64, ptr)> 
    %191 = llvm.insertvalue %188, %190[1] : !llvm.struct<(i64, ptr)> 
    %192 = llvm.mlir.constant(1 : index) : i64
    %193 = llvm.alloca %192 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %185, %193 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %194 = llvm.alloca %192 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %191, %194 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %195 = llvm.mlir.zero : !llvm.ptr
    %196 = llvm.getelementptr %195[1] : (!llvm.ptr) -> !llvm.ptr, f32
    %197 = llvm.ptrtoint %196 : !llvm.ptr to i64
    llvm.call @memrefCopy(%197, %193, %194) : (i64, !llvm.ptr, !llvm.ptr) -> ()
    llvm.intr.stackrestore %179 : !llvm.ptr
    %198 = llvm.add %92, %25  : i64
    llvm.br ^bb9(%198 : i64)
  ^bb20:  // pred: ^bb9
    %199 = llvm.add %90, %25  : i64
    llvm.br ^bb7(%199 : i64)
  ^bb21:  // pred: ^bb7
    llvm.br ^bb22(%27 : i64)
  ^bb22(%200: i64):  // 2 preds: ^bb21, ^bb26
    %201 = llvm.icmp "slt" %200, %26 : i64
    llvm.cond_br %201, ^bb23, ^bb27
  ^bb23:  // pred: ^bb22
    llvm.br ^bb24(%27 : i64)
  ^bb24(%202: i64):  // 2 preds: ^bb23, ^bb25
    %203 = llvm.icmp "slt" %202, %24 : i64
    llvm.cond_br %203, ^bb25, ^bb26
  ^bb25:  // pred: ^bb24
    %204 = llvm.mlir.constant(256 : index) : i64
    %205 = llvm.mul %200, %204  : i64
    %206 = llvm.add %205, %202  : i64
    %207 = llvm.getelementptr %70[%206] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %208 = llvm.load %207 : !llvm.ptr -> f32
    %209 = llvm.getelementptr %arg15[%202] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %210 = llvm.load %209 : !llvm.ptr -> f32
    %211 = llvm.fadd %208, %210  : f32
    %212 = llvm.mlir.constant(256 : index) : i64
    %213 = llvm.mul %200, %212  : i64
    %214 = llvm.add %213, %202  : i64
    %215 = llvm.getelementptr %44[%214] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %211, %215 : f32, !llvm.ptr
    %216 = llvm.add %202, %23  : i64
    llvm.br ^bb24(%216 : i64)
  ^bb26:  // pred: ^bb24
    %217 = llvm.add %200, %23  : i64
    llvm.br ^bb22(%217 : i64)
  ^bb27:  // pred: ^bb22
    llvm.br ^bb28(%27 : i64)
  ^bb28(%218: i64):  // 2 preds: ^bb27, ^bb32
    %219 = llvm.icmp "slt" %218, %26 : i64
    llvm.cond_br %219, ^bb29, ^bb33
  ^bb29:  // pred: ^bb28
    llvm.br ^bb30(%27 : i64)
  ^bb30(%220: i64):  // 2 preds: ^bb29, ^bb31
    %221 = llvm.icmp "slt" %220, %24 : i64
    llvm.cond_br %221, ^bb31, ^bb32
  ^bb31:  // pred: ^bb30
    %222 = llvm.mlir.constant(256 : index) : i64
    %223 = llvm.mul %218, %222  : i64
    %224 = llvm.add %223, %220  : i64
    %225 = llvm.getelementptr %44[%224] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %226 = llvm.load %225 : !llvm.ptr -> f32
    %227 = llvm.intr.maximum(%226, %22)  : (f32, f32) -> f32
    %228 = llvm.mlir.constant(256 : index) : i64
    %229 = llvm.mul %218, %228  : i64
    %230 = llvm.add %229, %220  : i64
    %231 = llvm.getelementptr %44[%230] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %227, %231 : f32, !llvm.ptr
    %232 = llvm.add %220, %23  : i64
    llvm.br ^bb30(%232 : i64)
  ^bb32:  // pred: ^bb30
    %233 = llvm.add %218, %23  : i64
    llvm.br ^bb28(%233 : i64)
  ^bb33:  // pred: ^bb28
    %234 = llvm.mlir.undef : !llvm.struct<(struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>)>
    %235 = llvm.insertvalue %53, %234[0] : !llvm.struct<(struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>)> 
    %236 = llvm.insertvalue %79, %235[1] : !llvm.struct<(struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>)> 
    llvm.return %236 : !llvm.struct<(struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>)>
  }
}

