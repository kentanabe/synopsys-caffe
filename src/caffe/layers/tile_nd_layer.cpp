#include <vector>

#include "caffe/layers/tile_nd_layer.hpp"
#include "caffe/util/math_functions.hpp"

namespace caffe {

template <typename Dtype>
void TileNDLayer<Dtype>::LayerSetUp(
    const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  const TileNDParameter& tile_nd_param = this->layer_param_.tile_nd_param();
  axis_.clear();
  std::copy(tile_nd_param.axis().begin(),
    tile_nd_param.axis().end(),
    std::back_inserter(axis_));
  tiles_.clear();
  std::copy(tile_nd_param.tiles().begin(),
    tile_nd_param.tiles().end(),
    std::back_inserter(tiles_));

  CHECK_EQ(axis_.size(), tiles_.size()) << "Number of tiles must be equal to axis!";
  CHECK_GT(tiles_.size(), 0) << "Number of tiles must be positive!";
  for(int i=0;i<axis_.size();i++)
  {
    axis_[i] = bottom[0]->CanonicalAxisIndex(axis_[i]);
    CHECK_GT(tiles_[i], 0) << "Value of tiles must be positive!";
  }
}


template <typename Dtype>
void TileNDLayer<Dtype>::Reshape(
    const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  vector<int> top_shape = bottom[0]->shape();
  for(int i=axis_.size()-1;i>=0;i--)
    top_shape[axis_[i]] = bottom[0]->shape(axis_[i]) * tiles_[i];
  top[0]->Reshape(top_shape);
}

template <typename Dtype>
void TileNDLayer<Dtype>::Forward_cpu(
    const vector<Blob<Dtype>*>& bottom, const vector<Blob<Dtype>*>& top) {
  const Dtype* bottom_data = bottom[0]->cpu_data();
  Dtype* top_data = top[0]->mutable_cpu_data();
  int count = top[0]->count();
  int dim = top[0]->num_axes();
  // Assume top index (x,y,z) with top shape (A, B, C)
  // top offset d = xBC + yC + z
  // So to count the bottom index, should first figure out x, y, z
  // x = d / BC
  // y = (d % BC) / C
  // z = d % C
  // Then consider bottom shape (A', B', C'), where A' * tiles[axis] = A
  // So bottom offset = x'B'C' + y'C' + z
  for(int d=0; d<count; d++)
  {
    int offset = 0;
    for(int i=0;i<dim-1;i++)
    {
      int num = (d % top[0]->count(i)) / top[0]->count(i+1);
      int n0 = num % bottom[0]->shape(i);
      offset += n0 * bottom[0]->count(i+1);
    }
    int z = d % top[0]->shape(dim-1);
    int z0 = z % bottom[0]->shape(dim-1);
    offset += z0;

    top_data[d] = bottom_data[offset];
  }
}

template <typename Dtype>
void TileNDLayer<Dtype>::Backward_cpu(const vector<Blob<Dtype>*>& top,
    const vector<bool>& propagate_down, const vector<Blob<Dtype>*>& bottom) {
  NOT_IMPLEMENTED;
}

//#ifdef CPU_ONLY
//STUB_GPU(TileLayer);
//#endif

INSTANTIATE_CLASS(TileNDLayer);
REGISTER_LAYER_CLASS(TileND);

}  // namespace caffe
