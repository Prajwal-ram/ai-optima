module {
  llvm.func @memrefCopy(i64, !llvm.ptr, !llvm.ptr)
  llvm.func @malloc(i64) -> !llvm.ptr
  llvm.func @dense_layer(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> {
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
    %24 = llvm.mlir.constant(32 : index) : i64
    %25 = llvm.mlir.constant(128 : index) : i64
    %26 = llvm.mlir.constant(64 : index) : i64
    %27 = llvm.mlir.constant(0 : index) : i64
    %28 = llvm.mlir.constant(32 : index) : i64
    %29 = llvm.mlir.constant(64 : index) : i64
    %30 = llvm.mlir.constant(1 : index) : i64
    %31 = llvm.mlir.constant(2048 : index) : i64
    %32 = llvm.mlir.zero : !llvm.ptr
    %33 = llvm.getelementptr %32[2048] : (!llvm.ptr) -> !llvm.ptr, f32
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
    %54 = llvm.mlir.constant(32 : index) : i64
    %55 = llvm.mlir.constant(64 : index) : i64
    %56 = llvm.mlir.constant(1 : index) : i64
    %57 = llvm.mlir.constant(2048 : index) : i64
    %58 = llvm.mlir.zero : !llvm.ptr
    %59 = llvm.getelementptr %58[2048] : (!llvm.ptr) -> !llvm.ptr, f32
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
    %81 = llvm.icmp "slt" %80, %24 : i64
    llvm.cond_br %81, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%27 : i64)
  ^bb3(%82: i64):  // 2 preds: ^bb2, ^bb4
    %83 = llvm.icmp "slt" %82, %26 : i64
    llvm.cond_br %83, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %84 = llvm.mlir.constant(64 : index) : i64
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
  ^bb7(%90: i64):  // 2 preds: ^bb6, ^bb17
    %91 = llvm.icmp "slt" %90, %25 : i64
    llvm.cond_br %91, ^bb8, ^bb18
  ^bb8:  // pred: ^bb7
    %92 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %93 = llvm.insertvalue %arg0, %92[0] : !llvm.struct<(ptr, ptr, i64)> 
    %94 = llvm.insertvalue %arg1, %93[1] : !llvm.struct<(ptr, ptr, i64)> 
    %95 = llvm.mlir.constant(0 : index) : i64
    %96 = llvm.insertvalue %95, %94[2] : !llvm.struct<(ptr, ptr, i64)> 
    %97 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %98 = llvm.insertvalue %arg0, %97[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %99 = llvm.insertvalue %arg1, %98[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %100 = llvm.insertvalue %90, %99[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %101 = llvm.mlir.constant(32 : index) : i64
    %102 = llvm.insertvalue %101, %100[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %103 = llvm.mlir.constant(128 : index) : i64
    %104 = llvm.insertvalue %103, %102[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %105 = llvm.mlir.constant(64 : index) : i64
    %106 = llvm.insertvalue %105, %104[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %107 = llvm.mlir.constant(1 : index) : i64
    %108 = llvm.insertvalue %107, %106[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %109 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %110 = llvm.insertvalue %arg7, %109[0] : !llvm.struct<(ptr, ptr, i64)> 
    %111 = llvm.insertvalue %arg8, %110[1] : !llvm.struct<(ptr, ptr, i64)> 
    %112 = llvm.mlir.constant(0 : index) : i64
    %113 = llvm.insertvalue %112, %111[2] : !llvm.struct<(ptr, ptr, i64)> 
    %114 = llvm.mlir.constant(64 : index) : i64
    %115 = llvm.mul %90, %114  : i64
    %116 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %117 = llvm.insertvalue %arg7, %116[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %118 = llvm.insertvalue %arg8, %117[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %119 = llvm.insertvalue %115, %118[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %120 = llvm.mlir.constant(64 : index) : i64
    %121 = llvm.insertvalue %120, %119[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.mlir.constant(64 : index) : i64
    %123 = llvm.insertvalue %122, %121[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.mlir.constant(64 : index) : i64
    %125 = llvm.insertvalue %124, %123[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.mlir.constant(1 : index) : i64
    %127 = llvm.insertvalue %126, %125[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb9(%27 : i64)
  ^bb9(%128: i64):  // 2 preds: ^bb8, ^bb16
    %129 = llvm.icmp "slt" %128, %24 : i64
    llvm.cond_br %129, ^bb10, ^bb17
  ^bb10:  // pred: ^bb9
    llvm.br ^bb11(%27 : i64)
  ^bb11(%130: i64):  // 2 preds: ^bb10, ^bb15
    %131 = llvm.icmp "slt" %130, %26 : i64
    llvm.cond_br %131, ^bb12, ^bb16
  ^bb12:  // pred: ^bb11
    llvm.br ^bb13(%27 : i64)
  ^bb13(%132: i64):  // 2 preds: ^bb12, ^bb14
    %133 = llvm.icmp "slt" %132, %26 : i64
    llvm.cond_br %133, ^bb14, ^bb15
  ^bb14:  // pred: ^bb13
    %134 = llvm.getelementptr %arg1[%90] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %135 = llvm.mlir.constant(128 : index) : i64
    %136 = llvm.mul %128, %135  : i64
    %137 = llvm.add %136, %132  : i64
    %138 = llvm.getelementptr %134[%137] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %139 = llvm.load %138 : !llvm.ptr -> f32
    %140 = llvm.getelementptr %arg8[%115] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %141 = llvm.mlir.constant(64 : index) : i64
    %142 = llvm.mul %132, %141  : i64
    %143 = llvm.add %142, %130  : i64
    %144 = llvm.getelementptr %140[%143] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %145 = llvm.load %144 : !llvm.ptr -> f32
    %146 = llvm.mlir.constant(64 : index) : i64
    %147 = llvm.mul %128, %146  : i64
    %148 = llvm.add %147, %130  : i64
    %149 = llvm.getelementptr %70[%148] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %150 = llvm.load %149 : !llvm.ptr -> f32
    %151 = llvm.fmul %139, %145  : f32
    %152 = llvm.fadd %150, %151  : f32
    %153 = llvm.mlir.constant(64 : index) : i64
    %154 = llvm.mul %128, %153  : i64
    %155 = llvm.add %154, %130  : i64
    %156 = llvm.getelementptr %70[%155] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %152, %156 : f32, !llvm.ptr
    %157 = llvm.add %132, %23  : i64
    llvm.br ^bb13(%157 : i64)
  ^bb15:  // pred: ^bb13
    %158 = llvm.add %130, %23  : i64
    llvm.br ^bb11(%158 : i64)
  ^bb16:  // pred: ^bb11
    %159 = llvm.add %128, %23  : i64
    llvm.br ^bb9(%159 : i64)
  ^bb17:  // pred: ^bb9
    %160 = llvm.add %90, %26  : i64
    llvm.br ^bb7(%160 : i64)
  ^bb18:  // pred: ^bb7
    llvm.br ^bb19(%27 : i64)
  ^bb19(%161: i64):  // 2 preds: ^bb18, ^bb23
    %162 = llvm.icmp "slt" %161, %24 : i64
    llvm.cond_br %162, ^bb20, ^bb24
  ^bb20:  // pred: ^bb19
    llvm.br ^bb21(%27 : i64)
  ^bb21(%163: i64):  // 2 preds: ^bb20, ^bb22
    %164 = llvm.icmp "slt" %163, %26 : i64
    llvm.cond_br %164, ^bb22, ^bb23
  ^bb22:  // pred: ^bb21
    %165 = llvm.mlir.constant(64 : index) : i64
    %166 = llvm.mul %161, %165  : i64
    %167 = llvm.add %166, %163  : i64
    %168 = llvm.getelementptr %70[%167] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %169 = llvm.load %168 : !llvm.ptr -> f32
    %170 = llvm.getelementptr %arg15[%163] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %171 = llvm.load %170 : !llvm.ptr -> f32
    %172 = llvm.fadd %169, %171  : f32
    %173 = llvm.intr.maximum(%172, %22)  : (f32, f32) -> f32
    %174 = llvm.mlir.constant(64 : index) : i64
    %175 = llvm.mul %161, %174  : i64
    %176 = llvm.add %175, %163  : i64
    %177 = llvm.getelementptr %44[%176] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %173, %177 : f32, !llvm.ptr
    %178 = llvm.add %163, %23  : i64
    llvm.br ^bb21(%178 : i64)
  ^bb23:  // pred: ^bb21
    %179 = llvm.add %161, %23  : i64
    llvm.br ^bb19(%179 : i64)
  ^bb24:  // pred: ^bb19
    llvm.return %53 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
  llvm.func @two_layer_mlp(%arg0: !llvm.ptr, %arg1: !llvm.ptr, %arg2: i64, %arg3: i64, %arg4: i64, %arg5: i64, %arg6: i64, %arg7: !llvm.ptr, %arg8: !llvm.ptr, %arg9: i64, %arg10: i64, %arg11: i64, %arg12: i64, %arg13: i64, %arg14: !llvm.ptr, %arg15: !llvm.ptr, %arg16: i64, %arg17: i64, %arg18: i64, %arg19: !llvm.ptr, %arg20: !llvm.ptr, %arg21: i64, %arg22: i64, %arg23: i64, %arg24: i64, %arg25: i64, %arg26: !llvm.ptr, %arg27: !llvm.ptr, %arg28: i64, %arg29: i64, %arg30: i64) -> !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> {
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
    %22 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %23 = llvm.insertvalue %arg19, %22[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %24 = llvm.insertvalue %arg20, %23[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %25 = llvm.insertvalue %arg21, %24[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %26 = llvm.insertvalue %arg22, %25[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %27 = llvm.insertvalue %arg24, %26[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %28 = llvm.insertvalue %arg23, %27[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %29 = llvm.insertvalue %arg25, %28[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %30 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)>
    %31 = llvm.insertvalue %arg26, %30[0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %32 = llvm.insertvalue %arg27, %31[1] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %33 = llvm.insertvalue %arg28, %32[2] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %34 = llvm.insertvalue %arg29, %33[3, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %35 = llvm.insertvalue %arg30, %34[4, 0] : !llvm.struct<(ptr, ptr, i64, array<1 x i64>, array<1 x i64>)> 
    %36 = llvm.mlir.constant(-1 : index) : i64
    %37 = llvm.mlir.constant(0.000000e+00 : f32) : f32
    %38 = llvm.mlir.constant(10 : index) : i64
    %39 = llvm.mlir.constant(1 : index) : i64
    %40 = llvm.mlir.constant(32 : index) : i64
    %41 = llvm.mlir.constant(784 : index) : i64
    %42 = llvm.mlir.constant(256 : index) : i64
    %43 = llvm.mlir.constant(64 : index) : i64
    %44 = llvm.mlir.constant(0 : index) : i64
    %45 = llvm.mlir.constant(32 : index) : i64
    %46 = llvm.mlir.constant(256 : index) : i64
    %47 = llvm.mlir.constant(1 : index) : i64
    %48 = llvm.mlir.constant(8192 : index) : i64
    %49 = llvm.mlir.zero : !llvm.ptr
    %50 = llvm.getelementptr %49[8192] : (!llvm.ptr) -> !llvm.ptr, f32
    %51 = llvm.ptrtoint %50 : !llvm.ptr to i64
    %52 = llvm.mlir.constant(64 : index) : i64
    %53 = llvm.add %51, %52  : i64
    %54 = llvm.call @malloc(%53) : (i64) -> !llvm.ptr
    %55 = llvm.ptrtoint %54 : !llvm.ptr to i64
    %56 = llvm.mlir.constant(1 : index) : i64
    %57 = llvm.sub %52, %56  : i64
    %58 = llvm.add %55, %57  : i64
    %59 = llvm.urem %58, %52  : i64
    %60 = llvm.sub %58, %59  : i64
    %61 = llvm.inttoptr %60 : i64 to !llvm.ptr
    %62 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %63 = llvm.insertvalue %54, %62[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %64 = llvm.insertvalue %61, %63[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %65 = llvm.mlir.constant(0 : index) : i64
    %66 = llvm.insertvalue %65, %64[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %67 = llvm.insertvalue %45, %66[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %68 = llvm.insertvalue %46, %67[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %69 = llvm.insertvalue %46, %68[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %70 = llvm.insertvalue %47, %69[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %71 = llvm.mlir.constant(32 : index) : i64
    %72 = llvm.mlir.constant(256 : index) : i64
    %73 = llvm.mlir.constant(1 : index) : i64
    %74 = llvm.mlir.constant(8192 : index) : i64
    %75 = llvm.mlir.zero : !llvm.ptr
    %76 = llvm.getelementptr %75[8192] : (!llvm.ptr) -> !llvm.ptr, f32
    %77 = llvm.ptrtoint %76 : !llvm.ptr to i64
    %78 = llvm.mlir.constant(64 : index) : i64
    %79 = llvm.add %77, %78  : i64
    %80 = llvm.call @malloc(%79) : (i64) -> !llvm.ptr
    %81 = llvm.ptrtoint %80 : !llvm.ptr to i64
    %82 = llvm.mlir.constant(1 : index) : i64
    %83 = llvm.sub %78, %82  : i64
    %84 = llvm.add %81, %83  : i64
    %85 = llvm.urem %84, %78  : i64
    %86 = llvm.sub %84, %85  : i64
    %87 = llvm.inttoptr %86 : i64 to !llvm.ptr
    %88 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %89 = llvm.insertvalue %80, %88[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %90 = llvm.insertvalue %87, %89[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %91 = llvm.mlir.constant(0 : index) : i64
    %92 = llvm.insertvalue %91, %90[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %93 = llvm.insertvalue %71, %92[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %94 = llvm.insertvalue %72, %93[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %95 = llvm.insertvalue %72, %94[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %96 = llvm.insertvalue %73, %95[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb1(%44 : i64)
  ^bb1(%97: i64):  // 2 preds: ^bb0, ^bb5
    %98 = llvm.icmp "slt" %97, %40 : i64
    llvm.cond_br %98, ^bb2, ^bb6
  ^bb2:  // pred: ^bb1
    llvm.br ^bb3(%44 : i64)
  ^bb3(%99: i64):  // 2 preds: ^bb2, ^bb4
    %100 = llvm.icmp "slt" %99, %42 : i64
    llvm.cond_br %100, ^bb4, ^bb5
  ^bb4:  // pred: ^bb3
    %101 = llvm.mlir.constant(256 : index) : i64
    %102 = llvm.mul %97, %101  : i64
    %103 = llvm.add %102, %99  : i64
    %104 = llvm.getelementptr %87[%103] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %37, %104 : f32, !llvm.ptr
    %105 = llvm.add %99, %39  : i64
    llvm.br ^bb3(%105 : i64)
  ^bb5:  // pred: ^bb3
    %106 = llvm.add %97, %39  : i64
    llvm.br ^bb1(%106 : i64)
  ^bb6:  // pred: ^bb1
    llvm.br ^bb7(%44 : i64)
  ^bb7(%107: i64):  // 2 preds: ^bb6, ^bb20
    %108 = llvm.icmp "slt" %107, %42 : i64
    llvm.cond_br %108, ^bb8, ^bb21
  ^bb8:  // pred: ^bb7
    llvm.br ^bb9(%44 : i64)
  ^bb9(%109: i64):  // 2 preds: ^bb8, ^bb19
    %110 = llvm.icmp "slt" %109, %41 : i64
    llvm.cond_br %110, ^bb10, ^bb20
  ^bb10:  // pred: ^bb9
    %111 = llvm.mul %109, %36  : i64
    %112 = llvm.add %111, %41  : i64
    %113 = llvm.icmp "slt" %112, %43 : i64
    %114 = llvm.select %113, %112, %43 : i1, i64
    %115 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %116 = llvm.insertvalue %arg0, %115[0] : !llvm.struct<(ptr, ptr, i64)> 
    %117 = llvm.insertvalue %arg1, %116[1] : !llvm.struct<(ptr, ptr, i64)> 
    %118 = llvm.mlir.constant(0 : index) : i64
    %119 = llvm.insertvalue %118, %117[2] : !llvm.struct<(ptr, ptr, i64)> 
    %120 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %121 = llvm.insertvalue %arg0, %120[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %122 = llvm.insertvalue %arg1, %121[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %123 = llvm.insertvalue %109, %122[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %124 = llvm.mlir.constant(32 : index) : i64
    %125 = llvm.insertvalue %124, %123[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %126 = llvm.mlir.constant(784 : index) : i64
    %127 = llvm.insertvalue %126, %125[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %128 = llvm.insertvalue %114, %127[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %129 = llvm.mlir.constant(1 : index) : i64
    %130 = llvm.insertvalue %129, %128[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %131 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %132 = llvm.insertvalue %arg7, %131[0] : !llvm.struct<(ptr, ptr, i64)> 
    %133 = llvm.insertvalue %arg8, %132[1] : !llvm.struct<(ptr, ptr, i64)> 
    %134 = llvm.mlir.constant(0 : index) : i64
    %135 = llvm.insertvalue %134, %133[2] : !llvm.struct<(ptr, ptr, i64)> 
    %136 = llvm.mlir.constant(256 : index) : i64
    %137 = llvm.mul %109, %136  : i64
    %138 = llvm.add %137, %107  : i64
    %139 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %140 = llvm.insertvalue %arg7, %139[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %141 = llvm.insertvalue %arg8, %140[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %142 = llvm.insertvalue %138, %141[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %143 = llvm.insertvalue %114, %142[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %144 = llvm.mlir.constant(256 : index) : i64
    %145 = llvm.insertvalue %144, %143[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %146 = llvm.mlir.constant(64 : index) : i64
    %147 = llvm.insertvalue %146, %145[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %148 = llvm.mlir.constant(1 : index) : i64
    %149 = llvm.insertvalue %148, %147[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %150 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %151 = llvm.insertvalue %80, %150[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %152 = llvm.insertvalue %87, %151[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %153 = llvm.insertvalue %107, %152[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %154 = llvm.mlir.constant(32 : index) : i64
    %155 = llvm.insertvalue %154, %153[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %156 = llvm.mlir.constant(256 : index) : i64
    %157 = llvm.insertvalue %156, %155[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %158 = llvm.mlir.constant(64 : index) : i64
    %159 = llvm.insertvalue %158, %157[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %160 = llvm.mlir.constant(1 : index) : i64
    %161 = llvm.insertvalue %160, %159[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb11(%44 : i64)
  ^bb11(%162: i64):  // 2 preds: ^bb10, ^bb18
    %163 = llvm.icmp "slt" %162, %40 : i64
    llvm.cond_br %163, ^bb12, ^bb19
  ^bb12:  // pred: ^bb11
    llvm.br ^bb13(%44 : i64)
  ^bb13(%164: i64):  // 2 preds: ^bb12, ^bb17
    %165 = llvm.icmp "slt" %164, %43 : i64
    llvm.cond_br %165, ^bb14, ^bb18
  ^bb14:  // pred: ^bb13
    llvm.br ^bb15(%44 : i64)
  ^bb15(%166: i64):  // 2 preds: ^bb14, ^bb16
    %167 = llvm.icmp "slt" %166, %114 : i64
    llvm.cond_br %167, ^bb16, ^bb17
  ^bb16:  // pred: ^bb15
    %168 = llvm.getelementptr %arg1[%109] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %169 = llvm.mlir.constant(784 : index) : i64
    %170 = llvm.mul %162, %169  : i64
    %171 = llvm.add %170, %166  : i64
    %172 = llvm.getelementptr %168[%171] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %173 = llvm.load %172 : !llvm.ptr -> f32
    %174 = llvm.getelementptr %arg8[%138] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %175 = llvm.mlir.constant(256 : index) : i64
    %176 = llvm.mul %166, %175  : i64
    %177 = llvm.add %176, %164  : i64
    %178 = llvm.getelementptr %174[%177] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %179 = llvm.load %178 : !llvm.ptr -> f32
    %180 = llvm.getelementptr %87[%107] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %181 = llvm.mlir.constant(256 : index) : i64
    %182 = llvm.mul %162, %181  : i64
    %183 = llvm.add %182, %164  : i64
    %184 = llvm.getelementptr %180[%183] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %185 = llvm.load %184 : !llvm.ptr -> f32
    %186 = llvm.fmul %173, %179  : f32
    %187 = llvm.fadd %185, %186  : f32
    %188 = llvm.getelementptr %87[%107] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %189 = llvm.mlir.constant(256 : index) : i64
    %190 = llvm.mul %162, %189  : i64
    %191 = llvm.add %190, %164  : i64
    %192 = llvm.getelementptr %188[%191] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %187, %192 : f32, !llvm.ptr
    %193 = llvm.add %166, %39  : i64
    llvm.br ^bb15(%193 : i64)
  ^bb17:  // pred: ^bb15
    %194 = llvm.add %164, %39  : i64
    llvm.br ^bb13(%194 : i64)
  ^bb18:  // pred: ^bb13
    %195 = llvm.add %162, %39  : i64
    llvm.br ^bb11(%195 : i64)
  ^bb19:  // pred: ^bb11
    %196 = llvm.intr.stacksave : !llvm.ptr
    %197 = llvm.mlir.constant(2 : i64) : i64
    %198 = llvm.mlir.constant(1 : index) : i64
    %199 = llvm.alloca %198 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %161, %199 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %200 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %201 = llvm.insertvalue %197, %200[0] : !llvm.struct<(i64, ptr)> 
    %202 = llvm.insertvalue %199, %201[1] : !llvm.struct<(i64, ptr)> 
    %203 = llvm.mlir.constant(2 : i64) : i64
    %204 = llvm.mlir.constant(1 : index) : i64
    %205 = llvm.alloca %204 x !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> : (i64) -> !llvm.ptr
    llvm.store %161, %205 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>, !llvm.ptr
    %206 = llvm.mlir.undef : !llvm.struct<(i64, ptr)>
    %207 = llvm.insertvalue %203, %206[0] : !llvm.struct<(i64, ptr)> 
    %208 = llvm.insertvalue %205, %207[1] : !llvm.struct<(i64, ptr)> 
    %209 = llvm.mlir.constant(1 : index) : i64
    %210 = llvm.alloca %209 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %202, %210 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %211 = llvm.alloca %209 x !llvm.struct<(i64, ptr)> : (i64) -> !llvm.ptr
    llvm.store %208, %211 : !llvm.struct<(i64, ptr)>, !llvm.ptr
    %212 = llvm.mlir.zero : !llvm.ptr
    %213 = llvm.getelementptr %212[1] : (!llvm.ptr) -> !llvm.ptr, f32
    %214 = llvm.ptrtoint %213 : !llvm.ptr to i64
    llvm.call @memrefCopy(%214, %210, %211) : (i64, !llvm.ptr, !llvm.ptr) -> ()
    llvm.intr.stackrestore %196 : !llvm.ptr
    %215 = llvm.add %109, %43  : i64
    llvm.br ^bb9(%215 : i64)
  ^bb20:  // pred: ^bb9
    %216 = llvm.add %107, %43  : i64
    llvm.br ^bb7(%216 : i64)
  ^bb21:  // pred: ^bb7
    llvm.br ^bb22(%44 : i64)
  ^bb22(%217: i64):  // 2 preds: ^bb21, ^bb26
    %218 = llvm.icmp "slt" %217, %40 : i64
    llvm.cond_br %218, ^bb23, ^bb27
  ^bb23:  // pred: ^bb22
    llvm.br ^bb24(%44 : i64)
  ^bb24(%219: i64):  // 2 preds: ^bb23, ^bb25
    %220 = llvm.icmp "slt" %219, %42 : i64
    llvm.cond_br %220, ^bb25, ^bb26
  ^bb25:  // pred: ^bb24
    %221 = llvm.mlir.constant(256 : index) : i64
    %222 = llvm.mul %217, %221  : i64
    %223 = llvm.add %222, %219  : i64
    %224 = llvm.getelementptr %87[%223] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %225 = llvm.load %224 : !llvm.ptr -> f32
    %226 = llvm.getelementptr %arg15[%219] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %227 = llvm.load %226 : !llvm.ptr -> f32
    %228 = llvm.fadd %225, %227  : f32
    %229 = llvm.intr.maximum(%228, %37)  : (f32, f32) -> f32
    %230 = llvm.mlir.constant(256 : index) : i64
    %231 = llvm.mul %217, %230  : i64
    %232 = llvm.add %231, %219  : i64
    %233 = llvm.getelementptr %61[%232] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %229, %233 : f32, !llvm.ptr
    %234 = llvm.add %219, %39  : i64
    llvm.br ^bb24(%234 : i64)
  ^bb26:  // pred: ^bb24
    %235 = llvm.add %217, %39  : i64
    llvm.br ^bb22(%235 : i64)
  ^bb27:  // pred: ^bb22
    %236 = llvm.mlir.constant(32 : index) : i64
    %237 = llvm.mlir.constant(10 : index) : i64
    %238 = llvm.mlir.constant(1 : index) : i64
    %239 = llvm.mlir.constant(320 : index) : i64
    %240 = llvm.mlir.zero : !llvm.ptr
    %241 = llvm.getelementptr %240[320] : (!llvm.ptr) -> !llvm.ptr, f32
    %242 = llvm.ptrtoint %241 : !llvm.ptr to i64
    %243 = llvm.mlir.constant(64 : index) : i64
    %244 = llvm.add %242, %243  : i64
    %245 = llvm.call @malloc(%244) : (i64) -> !llvm.ptr
    %246 = llvm.ptrtoint %245 : !llvm.ptr to i64
    %247 = llvm.mlir.constant(1 : index) : i64
    %248 = llvm.sub %243, %247  : i64
    %249 = llvm.add %246, %248  : i64
    %250 = llvm.urem %249, %243  : i64
    %251 = llvm.sub %249, %250  : i64
    %252 = llvm.inttoptr %251 : i64 to !llvm.ptr
    %253 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %254 = llvm.insertvalue %245, %253[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %255 = llvm.insertvalue %252, %254[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %256 = llvm.mlir.constant(0 : index) : i64
    %257 = llvm.insertvalue %256, %255[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %258 = llvm.insertvalue %236, %257[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %259 = llvm.insertvalue %237, %258[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %260 = llvm.insertvalue %237, %259[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %261 = llvm.insertvalue %238, %260[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %262 = llvm.mlir.constant(32 : index) : i64
    %263 = llvm.mlir.constant(10 : index) : i64
    %264 = llvm.mlir.constant(1 : index) : i64
    %265 = llvm.mlir.constant(320 : index) : i64
    %266 = llvm.mlir.zero : !llvm.ptr
    %267 = llvm.getelementptr %266[320] : (!llvm.ptr) -> !llvm.ptr, f32
    %268 = llvm.ptrtoint %267 : !llvm.ptr to i64
    %269 = llvm.mlir.constant(64 : index) : i64
    %270 = llvm.add %268, %269  : i64
    %271 = llvm.call @malloc(%270) : (i64) -> !llvm.ptr
    %272 = llvm.ptrtoint %271 : !llvm.ptr to i64
    %273 = llvm.mlir.constant(1 : index) : i64
    %274 = llvm.sub %269, %273  : i64
    %275 = llvm.add %272, %274  : i64
    %276 = llvm.urem %275, %269  : i64
    %277 = llvm.sub %275, %276  : i64
    %278 = llvm.inttoptr %277 : i64 to !llvm.ptr
    %279 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %280 = llvm.insertvalue %271, %279[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %281 = llvm.insertvalue %278, %280[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %282 = llvm.mlir.constant(0 : index) : i64
    %283 = llvm.insertvalue %282, %281[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %284 = llvm.insertvalue %262, %283[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %285 = llvm.insertvalue %263, %284[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %286 = llvm.insertvalue %263, %285[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %287 = llvm.insertvalue %264, %286[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb28(%44 : i64)
  ^bb28(%288: i64):  // 2 preds: ^bb27, ^bb32
    %289 = llvm.icmp "slt" %288, %40 : i64
    llvm.cond_br %289, ^bb29, ^bb33
  ^bb29:  // pred: ^bb28
    llvm.br ^bb30(%44 : i64)
  ^bb30(%290: i64):  // 2 preds: ^bb29, ^bb31
    %291 = llvm.icmp "slt" %290, %38 : i64
    llvm.cond_br %291, ^bb31, ^bb32
  ^bb31:  // pred: ^bb30
    %292 = llvm.mlir.constant(10 : index) : i64
    %293 = llvm.mul %288, %292  : i64
    %294 = llvm.add %293, %290  : i64
    %295 = llvm.getelementptr %278[%294] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %37, %295 : f32, !llvm.ptr
    %296 = llvm.add %290, %39  : i64
    llvm.br ^bb30(%296 : i64)
  ^bb32:  // pred: ^bb30
    %297 = llvm.add %288, %39  : i64
    llvm.br ^bb28(%297 : i64)
  ^bb33:  // pred: ^bb28
    llvm.br ^bb34(%44 : i64)
  ^bb34(%298: i64):  // 2 preds: ^bb33, ^bb44
    %299 = llvm.icmp "slt" %298, %42 : i64
    llvm.cond_br %299, ^bb35, ^bb45
  ^bb35:  // pred: ^bb34
    %300 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %301 = llvm.insertvalue %54, %300[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %302 = llvm.insertvalue %61, %301[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %303 = llvm.insertvalue %298, %302[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %304 = llvm.mlir.constant(32 : index) : i64
    %305 = llvm.insertvalue %304, %303[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %306 = llvm.mlir.constant(256 : index) : i64
    %307 = llvm.insertvalue %306, %305[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %308 = llvm.mlir.constant(64 : index) : i64
    %309 = llvm.insertvalue %308, %307[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %310 = llvm.mlir.constant(1 : index) : i64
    %311 = llvm.insertvalue %310, %309[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %312 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64)>
    %313 = llvm.insertvalue %arg19, %312[0] : !llvm.struct<(ptr, ptr, i64)> 
    %314 = llvm.insertvalue %arg20, %313[1] : !llvm.struct<(ptr, ptr, i64)> 
    %315 = llvm.mlir.constant(0 : index) : i64
    %316 = llvm.insertvalue %315, %314[2] : !llvm.struct<(ptr, ptr, i64)> 
    %317 = llvm.mlir.constant(10 : index) : i64
    %318 = llvm.mul %298, %317  : i64
    %319 = llvm.mlir.undef : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
    %320 = llvm.insertvalue %arg19, %319[0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %321 = llvm.insertvalue %arg20, %320[1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %322 = llvm.insertvalue %318, %321[2] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %323 = llvm.mlir.constant(64 : index) : i64
    %324 = llvm.insertvalue %323, %322[3, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %325 = llvm.mlir.constant(10 : index) : i64
    %326 = llvm.insertvalue %325, %324[4, 0] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %327 = llvm.mlir.constant(10 : index) : i64
    %328 = llvm.insertvalue %327, %326[3, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    %329 = llvm.mlir.constant(1 : index) : i64
    %330 = llvm.insertvalue %329, %328[4, 1] : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)> 
    llvm.br ^bb36(%44 : i64)
  ^bb36(%331: i64):  // 2 preds: ^bb35, ^bb43
    %332 = llvm.icmp "slt" %331, %40 : i64
    llvm.cond_br %332, ^bb37, ^bb44
  ^bb37:  // pred: ^bb36
    llvm.br ^bb38(%44 : i64)
  ^bb38(%333: i64):  // 2 preds: ^bb37, ^bb42
    %334 = llvm.icmp "slt" %333, %38 : i64
    llvm.cond_br %334, ^bb39, ^bb43
  ^bb39:  // pred: ^bb38
    llvm.br ^bb40(%44 : i64)
  ^bb40(%335: i64):  // 2 preds: ^bb39, ^bb41
    %336 = llvm.icmp "slt" %335, %43 : i64
    llvm.cond_br %336, ^bb41, ^bb42
  ^bb41:  // pred: ^bb40
    %337 = llvm.getelementptr %61[%298] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %338 = llvm.mlir.constant(256 : index) : i64
    %339 = llvm.mul %331, %338  : i64
    %340 = llvm.add %339, %335  : i64
    %341 = llvm.getelementptr %337[%340] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %342 = llvm.load %341 : !llvm.ptr -> f32
    %343 = llvm.getelementptr %arg20[%318] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %344 = llvm.mlir.constant(10 : index) : i64
    %345 = llvm.mul %335, %344  : i64
    %346 = llvm.add %345, %333  : i64
    %347 = llvm.getelementptr %343[%346] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %348 = llvm.load %347 : !llvm.ptr -> f32
    %349 = llvm.mlir.constant(10 : index) : i64
    %350 = llvm.mul %331, %349  : i64
    %351 = llvm.add %350, %333  : i64
    %352 = llvm.getelementptr %278[%351] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %353 = llvm.load %352 : !llvm.ptr -> f32
    %354 = llvm.fmul %342, %348  : f32
    %355 = llvm.fadd %353, %354  : f32
    %356 = llvm.mlir.constant(10 : index) : i64
    %357 = llvm.mul %331, %356  : i64
    %358 = llvm.add %357, %333  : i64
    %359 = llvm.getelementptr %278[%358] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %355, %359 : f32, !llvm.ptr
    %360 = llvm.add %335, %39  : i64
    llvm.br ^bb40(%360 : i64)
  ^bb42:  // pred: ^bb40
    %361 = llvm.add %333, %39  : i64
    llvm.br ^bb38(%361 : i64)
  ^bb43:  // pred: ^bb38
    %362 = llvm.add %331, %39  : i64
    llvm.br ^bb36(%362 : i64)
  ^bb44:  // pred: ^bb36
    %363 = llvm.add %298, %43  : i64
    llvm.br ^bb34(%363 : i64)
  ^bb45:  // pred: ^bb34
    llvm.br ^bb46(%44 : i64)
  ^bb46(%364: i64):  // 2 preds: ^bb45, ^bb50
    %365 = llvm.icmp "slt" %364, %40 : i64
    llvm.cond_br %365, ^bb47, ^bb51
  ^bb47:  // pred: ^bb46
    llvm.br ^bb48(%44 : i64)
  ^bb48(%366: i64):  // 2 preds: ^bb47, ^bb49
    %367 = llvm.icmp "slt" %366, %38 : i64
    llvm.cond_br %367, ^bb49, ^bb50
  ^bb49:  // pred: ^bb48
    %368 = llvm.mlir.constant(10 : index) : i64
    %369 = llvm.mul %364, %368  : i64
    %370 = llvm.add %369, %366  : i64
    %371 = llvm.getelementptr %278[%370] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %372 = llvm.load %371 : !llvm.ptr -> f32
    %373 = llvm.getelementptr %arg27[%366] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    %374 = llvm.load %373 : !llvm.ptr -> f32
    %375 = llvm.fadd %372, %374  : f32
    %376 = llvm.intr.maximum(%375, %37)  : (f32, f32) -> f32
    %377 = llvm.mlir.constant(10 : index) : i64
    %378 = llvm.mul %364, %377  : i64
    %379 = llvm.add %378, %366  : i64
    %380 = llvm.getelementptr %252[%379] : (!llvm.ptr, i64) -> !llvm.ptr, f32
    llvm.store %376, %380 : f32, !llvm.ptr
    %381 = llvm.add %366, %39  : i64
    llvm.br ^bb48(%381 : i64)
  ^bb50:  // pred: ^bb48
    %382 = llvm.add %364, %39  : i64
    llvm.br ^bb46(%382 : i64)
  ^bb51:  // pred: ^bb46
    llvm.return %261 : !llvm.struct<(ptr, ptr, i64, array<2 x i64>, array<2 x i64>)>
  }
}

