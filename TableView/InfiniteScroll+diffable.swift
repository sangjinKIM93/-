import UIKit
import RxSwift
import RxCocoa

class InfiniteScrollTest: UIViewController {
    var dataSource: UITableViewDiffableDataSource<Int, TradeContentModel>!

    let tableView = UITableView().then {
        $0.rowHeight = 70
    }
    
    let apiCaller = APICaller()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        initDataSource()
        fetchItems(pagination: false)
    }

    private func setupView() {
        self.view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(InfiniteCell.self, forCellReuseIdentifier: InfiniteCell.identifier)
    }
        
    private func initDataSource() {
       dataSource = UITableViewDiffableDataSource<Int, TradeContentModel>(tableView: tableView, cellProvider: { tableView, indexPath, item in
           let cell = tableView.dequeueReusableCell(withIdentifier: InfiniteCell.identifier, for: indexPath) as! InfiniteCell
           cell.titleLabel1.text = item.price
           cell.titleLabel2.text = item.qty
           return cell
       })
       tableView.dataSource = dataSource

       var snapShot = NSDiffableDataSourceSnapshot<Int, TradeContentModel>()
       snapShot.appendSections([0])
       snapShot.appendItems([])
       dataSource.apply(snapShot)
    }
  
    private func fetchItems(pagination: Bool) {
        apiCaller.fetchData(pagination: pagination) { [weak self] result in
            switch result {
            case .success(let items):
               self?.appendSnapShot(items: items)
                
            case .failure(let error):
                print(error)
            }
        }
    }

    private func appendSnapShot(items: [TradeContentModel]) {
        var snapShot = dataSource.snapshot()
        snapShot.appendItems(items)
        
        dataSource.apply(snapShot)
    }
}

extension InfiniteScrollTest: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y

        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            
            guard !apiCaller.isPaginating else {
                return
            }
            fetchItems(pagination: true)
        }
    }
}

// MARK: - API
class APICaller {
    var isPaginating = false
    var currentPage = 1
    
    func fetchData(pagination:Bool = false, completion: @escaping (Result<[TradeContentModel], Error>) -> Void){

        if pagination {
            isPaginating = true
        }

      // API 예시. page를 하나씩 늘리면서 다음 page를 호출
      // response로 오는 totalPage보다 currentPage가 크면 page를 쏘지 않음
        APIManager.request(
            target: .getTrade(page: currentPage, perPage: 30),
            responseType: TradeModel.self) { [weak self] response in
                guard let self = self else { return }
                guard reponse.page.totalCount < page else {
                   completion(.failure(error))
                   return
                }
                self.currentPage = response.page.currentPage
                if pagination {
                    self.isPaginating = false
                }
                completion(.success(response.content))
            } failure: { [weak self] error in
                guard let self = self else { return }
                if pagination {
                    self.isPaginating = false
                }
                completion(.failure(error))
            }
    }
}

class InfiniteCell: UITableViewCell {
    static let identifier = "InfiniteCell"
    
    let titleLabel1 = UILabel()
    let titleLabel2 = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupView() {
        self.addSubviews(titleLabel1, titleLabel2)
        
        titleLabel1.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        titleLabel2.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}

// MARK: - Model
struct TradeModel: Codable {
    let content: [TradeContentModel]
    let page: PageModel
}

struct TradeContentModel: Codable, Hashable {
    let tradeID: Double
    let price: String
    let qty: String
    
    enum CodingKeys: String, CodingKey {
        case tradeID = "trade_id"
        case price = "price"
        case qty = "qty"
    }
}

struct PageModel: Codable {
    let currentPage: Int
    let totalPage: Int
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case totalPage = "total_page"
        case totalCount = "total_count"
    }
}
